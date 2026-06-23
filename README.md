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

## Encrypted credentials (RSAEncrypter)

`lib/security/rsa.dart` defines `RSAEncrypter`, a singleton used to encrypt sensitive data (email, password, password-reset codes) before sending it to the backend — see its usages in `lib/database/mongodb_connector.dart`.

`RSAEncrypter.encryptData(plainText)`:
1. Loads the PEM-encoded RSA **public** key from `assets/keys/public_key.pem` via `rootBundle`.
2. Parses it with `RSAKeyParser` (from `pointycastle`).
3. Encrypts `plainText` with RSA/OAEP (SHA-1) using the `encrypt` package.
4. Returns the ciphertext as a base64 string.

The matching private key is held server-side only and never ships with the app. `assets/keys/public_key.pem` must therefore exist locally (it's declared as an asset folder via `assets/keys/` in `pubspec.yaml`) and must be the public key for whichever backend the app talks to — swap this file if you point the app at a different server.
