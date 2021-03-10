package com.example.memorare

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant

class Application: FlutterApplication(), PluginRegistrantCallback {
  override fun onCreate() {
    super.onCreate()
  }

  override fun registerWith(registry: PluginRegistry?) {
  }
}