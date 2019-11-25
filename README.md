# memorare

Official Memorare mobile (Android & iOS) app.

<img src="./screenshot.png" alt="mobile screenshot" title="mobile screenshot" width="300" />

## Getting Started

* Pre-requisites

Make sure you have Flutter dev tools installed.
You can test that by running the following command in a terminal:

```bash
flutter doctor -v
```

This will check that everything is alright.

If you don't have the flutter dev tools yet, please visit the official page.

* Clone the project

```bash
git clone https://github.com/memorare/mobile.git
```

* Add the file `assets/api.json` containing the api endpoint with your private key:

```json
{
  "apikey": "my_api_key",
  "url": "api_endpoint_url"
}
```

* Run the app using Android Studio, VSCode or the Command line interface

```bash
flutter run lib/main.dart
```

## Licence

MIT
