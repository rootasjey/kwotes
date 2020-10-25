<p align="middle">
  <img src="./assets/images/app-icon-512.png" title="fig.style icon" width="200"/>
</p>

<p align="middle">5 seconds of emotion</p>

<p align="middle">
  <img src="./screenshots/ooc-letterhead-envelope.png" title="fig.style home web" />
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
<br>
<br>
<br>

# Table of Contents

- [Status](#status)
- [Download](#download)
- [Table of Contents](#table-of-contents)
- [Presentation](#presentation)
- [Add a quote](#add-a-quote)
- [Roadmap](#roadmap)
- [Contribute](#contribute)
    - [PLEASE READ](#please-read)
  - [Code styles](#code-styles)
    - [Dart class](#dart-class)
- [License](#license)
- [Privacy Policy](#privacy-policy)
- [Help Center](#help-center)
- [Screenshots](#screenshots)

# Presentation

fig.style is a quotes app and service delivering one quote each day. It's available on multiplatform and has multilanguage. It only support English & French for now.

# Add a quote

You can freely add a quote to the app after creating an account. You can only add one quote per day but you can save the excedent as drafts.

Quotes are manually validated and can be rejected for various reasons:

* Hard to understand due to missing or partial information
* Strong language or offensive words
* Too ordinary (the sentence don't have any particularity - e.g.: The sun is red)

Adding an author or a reference is highly appreciated. It helps to better understand the quote and it's funnier.

# Roadmap

* Fix notifications (mobile)
* Re-work web home page

# Contribute

### PLEASE READ

> ⚠️ This project is in early development stage so the developer part hasn't been built yet, so you won't be able to contribute to it at the moment without explicit authorization.

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

# License

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
