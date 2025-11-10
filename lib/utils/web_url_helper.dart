import 'package:flutter/foundation.dart' show kIsWeb;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void pushWebRoute(String studentId) {
  if (kIsWeb) {
    html.window.history.pushState(null, '', '#/home/$studentId');
  }
}

// URL-Parameter abrufen
Map<String, String> getUrlParameters() {
  final params = <String, String>{};
  final uri = Uri.parse(html.window.location.href);
  uri.queryParameters.forEach((key, value) {
    params[key] = value;
  });
  return params;
}
