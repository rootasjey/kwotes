<p align="middle">
  <img src="./assets/images/app-icon-512.png" title="outofcontext icon" width="200"/>
</p>

<h1 align="middle">Out Of Context</h1>

<p align="middle">5 seconds of emotion</p>

<p align="middle">
  <img src="./screenshots/ooc-letterhead-envelope.png" title="out of context home web" />
</p>

# Status

![Website](https://img.shields.io/website?down_color=lightgrey&down_message=offline&style=for-the-badge&up_color=blue&up_message=online&url=https%3A%2F%2Fwww.outofcontext.app)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/outofcontextapp/app?style=for-the-badge)
![GitHub Release Date](https://img.shields.io/github/release-date/outofcontextapp/app?style=for-the-badge)
![GitHub commits since latest release (by date)](https://img.shields.io/github/commits-since/outofcontextapp/app/latest?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/outofcontextapp/app?style=for-the-badge)

# Download

<span style="margin-right: 10px;">
  <a href="https://apps.apple.com/us/app/out-of-context/id1516117110?ls=1">
    <img src="./screenshots/app_store_badge.png" title="Ppp Store" width="200"/>
  </a>
</span>

<span style="margin-right: 10px;">
  <a href="https://play.google.com/store/apps/details?id=com.outofcontext.app">
    <img src="./screenshots/google_play_badge.png" title="Play Store" width="200"/>
  </a>
</span>

<span>
  <a href="https://www.outofcontext.app">
    <img src="./screenshots/web_badge.png" title="Web" width="200"/>
  </a>
</span>

# Quickstart

> ⚠️ This project is in early development stage so you may find bugs. The developer part hasn't been built yet, so you won't be able to contribute to it at the moment without explicit authorization.

## Pre-requisites

Make sure you have Flutter dev tools installed.
You can test that by running the following command in a terminal:

```bash
flutter doctor -v
```

This will check that everything is alright.

If you don't have the flutter dev tools yet, please visit the [official Flutter page](https://flutter.dev).

## Setup the project

1. Clone the project

```bash
git clone https://github.com/memorare/mobile.git
```

2. Fill up the file `lib/app_keys.json` with your url and your private key:

> You can find them at [dev.outofcontext.app](https://dev.outofcontext.app)

```dart
/// Will be available soon
```

* Run the app using Android Studio, VSCode or the Command line interface

```bash
flutter run lib/main.dart
```

# Contribute

You won't be able to contribute to this project at the moment without explicit authorization due to the early development stage and the missing developers section.

## Code styles

Repository code styles for better structure and reading.

### Dart class

Rules for dart classes.

* All imports at the top, ascending ordered alphabeticaly
* Variables declared at the top of the state

```dart
class _DashboardState extends State<Dashboard> {
  FirebaseUser userAuth;
  bool canManage = false;
  // ...
}
```

* Class methods in priority order:
  * Overrides (e.g. `initState`)
  * build method
  * Custom methods which return a widget
  * Other functions (e.g. auth functions, fetch data, ...)

# Licence

Mozilla Public License 2.0.

Please read the [LICENSE](./LICENSE) for more information.

Please [ask](mailto:github@outofcontext.app) if you have any doubt.

# Privacy Policy

You can find the platform's privacy policy at: [https://tos.outofcontext.app](https://tos.outofcontext.app)

# Help Center

You can find the help center at: [https://help.outofcontext.app](https://help.outofcontext.app)

# Screenshots

<p align="middle">
  <img src="./screenshots/ooc-mobile.png" title="out of context mobile" />
</p>
