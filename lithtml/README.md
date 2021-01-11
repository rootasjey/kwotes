<p align="center">
  <img width="200" src="../web/icons/icon-512.png"></img>
</p>

## fig.style (lit-html)

[![Built with open-wc recommendations](https://img.shields.io/badge/built%20with-open--wc-blue.svg)](https://github.com/open-wc)

[fig.style](https://fig.style) is a quotes app for mobile (Android, iOS) & web.

This lit-html frontend version is a minimal version for desktop and mobile.

**Pros**

* Useful while Flutter web version is in beta (because Flutter web is in development)
* Lightweight so mobile devices have quick access

**Cons**

* Maintain +1 code base

## Quickstart

To get started:

```sh
# clone the repo
git clone https://github.com/rootasjey/fig.style

# navigate to the lit-html folder
cd ./fig.style/lit-html

# install npm dependencies
yarn # or `npm install`

# run the app
yarn run start # or `npm start`
```

## Scripts

- `start` runs your app for development, reloading on file changes
- `start:build` runs your app after it has been built using the build command
- `build` builds your app and outputs it in your `dist` directory
- `test` runs your test suite with Web Test Runner
- `lint` runs the linter for your project

## Tooling configs

For most of the tools, the configuration is in the `package.json` to reduce the amount of files in your project.

If you customize the configuration a lot, you can consider moving them to individual files.