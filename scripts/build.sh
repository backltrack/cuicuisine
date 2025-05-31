#!/bin/bash

flutter build web --base-href "/ui/"
flutter build apk

if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    today=$(date '+%y%m%d')
    mv build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/cuicuisine-$today.apk
    echo "APK built successfully and renamed to cuicuisine-$today.apk"
fi