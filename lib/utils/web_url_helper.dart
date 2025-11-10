import 'package:flutter/foundation.dart' show kIsWeb;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pushWebRoute(String studentId) {
  if (kIsWeb) {
    html.window.history.pushState(null, '', '#/home/$studentId');
  }
}
