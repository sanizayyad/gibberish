package com.example.testproject

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin

class FlutterLocalNotificationPluginRegistrant {
    companion object CustomPluginRegistrant {
        fun registerWith(registry: PluginRegistry) {
            if (alreadyRegisteredWith(registry)) {
                return
            }
            FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
            FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"))
        }

        private fun alreadyRegisteredWith(registry: PluginRegistry): Boolean {
            val key: String = FlutterLocalNotificationPluginRegistrant::class.java.canonicalName
            if (registry.hasPlugin(key)) {
                return true
            }
            registry.registrarFor(key)
            return false
        }
    }
}

