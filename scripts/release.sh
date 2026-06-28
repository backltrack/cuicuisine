#!/bin/bash
# Publishes the current build/ output as a GitHub release on this repo, so the
# backend can fetch it instead of having the build committed into its repo.
# Requires GITHUB_TOKEN (a PAT with "Contents: Read and write" on this repo),
# read from a .env file at the project root if not already set, and an
# existing build (run scripts/build.sh first).
set -e

REPO="backltrack/cuicuisine"
WEB_DIR="build/web"
APK_DIR="build/app/outputs/flutter-apk"

cd "$(dirname "$0")/.."

if [ -z "$GITHUB_TOKEN" ] && [ -f .env ]; then
    set -a
    source .env
    set +a
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN is required. Set it in a .env file at the project root (GITHUB_TOKEN=...), a PAT with 'Contents: Read and write' on $REPO." >&2
    exit 1
fi

apk_file=$(ls -t "$APK_DIR"/cuicuisine-*.apk 2>/dev/null | head -n1)
if [ -z "$apk_file" ]; then
    echo "Error: no cuicuisine-*.apk found in $APK_DIR. Run scripts/build.sh first." >&2
    exit 1
fi

if [ ! -d "$WEB_DIR" ]; then
    echo "Error: $WEB_DIR not found. Run scripts/build.sh first." >&2
    exit 1
fi

tag="build-$(date '+%y%m%d-%H%M%S')"
web_zip="$(mktemp --suffix=.zip)"
trap 'rm -f "$web_zip"' EXIT

echo "Zipping $WEB_DIR..."
python3 -c "
import zipfile, pathlib
src = pathlib.Path('$WEB_DIR')
with zipfile.ZipFile('$web_zip', 'w', zipfile.ZIP_DEFLATED) as zf:
    for f in src.rglob('*'):
        if f.is_file():
            zf.write(f, f.relative_to(src))
"

echo "Creating release $tag..."
release_json=$(curl -sf -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/$REPO/releases" \
    -d "{\"tag_name\":\"$tag\",\"name\":\"$tag\"}")

upload_url=$(python3 -c "import sys, json; print(json.load(sys.stdin)['upload_url'].split('{')[0])" <<< "$release_json")

echo "Uploading web build..."
curl -sf -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/zip" \
    --data-binary @"$web_zip" \
    "$upload_url?name=cuicuisine-web.zip" > /dev/null

echo "Uploading $(basename "$apk_file")..."
curl -sf -X POST \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/vnd.android.package-archive" \
    --data-binary @"$apk_file" \
    "$upload_url?name=$(basename "$apk_file")" > /dev/null

echo "Released $tag: https://github.com/$REPO/releases/tag/$tag"
