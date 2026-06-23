# Cuicuisine

A recipe book app, built with Flutter (targets Android, Linux desktop and Web).

## Getting started

1. Install a Flutter SDK matching `^3.9.2` (see `pubspec.yaml`).
2. Fetch dependencies:
   ```sh
   flutter pub get
   ```
3. Make sure `assets/keys/public_key.pem` exists (see [Encrypted credentials (RSAEncrypter)](#encrypted-credentials-rsaencrypter) below) — the app won't be able to log in/sign up without it.
4. Run the app:
   ```sh
   flutter run
   ```

If you change localization files, the Hive models, or want updated launcher icons, see the relevant sections below before running the app.

## Localization

Translations live in `lib/l10n/*.arb` (main locale: `fr`). After editing an `.arb` file, regenerate the localization classes in `lib/generated/`:

```sh
dart run intl_utils:generate
```

This reads the `flutter_intl` section of `pubspec.yaml` and regenerates the `S` class and the per-locale message files used throughout the app (`S.of(context).xxx`).

## Launcher icons

The launcher icon source image is `assets/icons/icon.png`. To (re)generate the Android launcher icons from it, run:

```sh
dart run flutter_launcher_icons
```

The output is configured under `flutter_launcher_icons` in `pubspec.yaml` (adaptive icon background `#0b1313`).

## Code generation (build_runner)

The Hive models (`lib/models/data_model.dart`, `update_model.dart`, `sync_model.dart`) use `@HiveType`/`@HiveField` annotations and rely on generated `*.g.dart` adapters. These generated files are committed, so you only need to regenerate them after changing a model:

```sh
dart run build_runner build --delete-conflicting-outputs
```

## Bumping the schema version after a data model change

Whenever you add/change/remove a `@HiveField` on `AppUser`, `Recipe`, `Book`, or any other Hive model in `lib/models/data_model.dart` (or `update_model.dart`/`sync_model.dart`), existing installs already have data on disk in the old shape. To migrate it, bump `HiveMigration.currentVersion` in `lib/database/hive_migration.dart`:

```dart
class HiveMigration {
  static const int currentVersion = 1; // bump this, e.g. to 2
  ...
  static Future<void> _migrate(HiveConnector db, int version) async {
    switch (version) {
      case 1:
        // ...
      case 2:
        // backfill/transform the data for the new schema here
        break;
    }
  }
}
```

`HiveMigration.run()` is called once on startup (`lib/database/hive_db.dart`). It reads the schema version last persisted on the device, then runs every `_migrate` case between that version (exclusive) and `currentVersion` (inclusive), in order, before saving the new version. So:

1. Bump `currentVersion` by 1.
2. Add a matching `case <newVersion>:` in `_migrate` that transforms existing Hive data to satisfy the new model shape (e.g. backfilling a new required field).
3. Leave older `case` blocks untouched — they must stay so devices that are several versions behind still migrate step by step.

This is independent from the app's release version in `pubspec.yaml` (`version: x.y.z`), which is only checked against a `minimum_app_version` served by the backend (`lib/database/mongodb_connector.dart`) to block outdated app installs — it has no bearing on local Hive data and doesn't need to change just because a model changed.

## Encrypted credentials (RSAEncrypter)

`lib/security/rsa.dart` defines `RSAEncrypter`, a singleton used to encrypt sensitive data (email, password, password-reset codes) before sending it to the backend — see its usages in `lib/database/mongodb_connector.dart`.

`RSAEncrypter.encryptData(plainText)`:
1. Loads the PEM-encoded RSA **public** key from `assets/keys/public_key.pem` via `rootBundle`.
2. Parses it with `RSAKeyParser` (from `pointycastle`).
3. Encrypts `plainText` with RSA/OAEP (SHA-1) using the `encrypt` package.
4. Returns the ciphertext as a base64 string.

The matching private key is held server-side only and never ships with the app. `assets/keys/public_key.pem` must therefore exist locally (it's declared as an asset folder via `assets/keys/` in `pubspec.yaml`) and must be the public key for whichever backend the app talks to — swap this file if you point the app at a different server.
