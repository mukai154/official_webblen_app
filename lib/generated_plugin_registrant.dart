//
// Generated file. Do not edit.
//

// ignore: unused_import
import 'dart:ui';

import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:cloud_functions_web/cloud_functions_web.dart';
import 'package:connectivity_for_web/connectivity_for_web.dart';
import 'package:firebase_analytics_web/firebase_analytics_web.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:location_web/location_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:video_player_web/video_player_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(PluginRegistry registry) {
  FirebaseFirestoreWeb.registerWith(registry.registrarFor(FirebaseFirestoreWeb));
  FirebaseFunctionsWeb.registerWith(registry.registrarFor(FirebaseFunctionsWeb));
  ConnectivityPlugin.registerWith(registry.registrarFor(ConnectivityPlugin));
  FirebaseAnalyticsWeb.registerWith(registry.registrarFor(FirebaseAnalyticsWeb));
  FirebaseAuthWeb.registerWith(registry.registrarFor(FirebaseAuthWeb));
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  GoogleSignInPlugin.registerWith(registry.registrarFor(GoogleSignInPlugin));
  LocationWebPlugin.registerWith(registry.registrarFor(LocationWebPlugin));
  UrlLauncherPlugin.registerWith(registry.registrarFor(UrlLauncherPlugin));
  VideoPlayerPlugin.registerWith(registry.registrarFor(VideoPlayerPlugin));
  registry.registerMessageHandler();
}
