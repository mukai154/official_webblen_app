package com.webblen.events.webblen;
import  io.flutter.app.FlutterApllication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.view.FlutterMain;
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService;

class Application : FlutterApplication(), PluginRegistrantCallback() {

    override fun onCreate(){
        super.onCreate();
        FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
        FlutterMain.startInitialization(this);
    }

    override fun registerWith(registry: PluginRegistry?){}
}