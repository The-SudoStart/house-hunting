import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Configures the HTTP client and base URL for backend API communication.
///
/// The base URL is platform-aware:
/// - Web / iOS simulator / other: `127.0.0.1:3000`
/// - Android emulator: `10.0.2.2:3000`
///
/// The [client] is injectable so tests can provide a [MockClient].
class ApiClient {
  static http.Client client = http.Client();

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://127.0.0.1:3000';
  }
}
