import 'package:universal_html/html.dart' as html;

class LocalStorageService {
  static void saveRefreshToken(String refreshToken) {
    html.window.localStorage['refreshToken'] = refreshToken;
  }

  static String? getRefreshToken() {
    return html.window.localStorage['refreshToken'];
  }

  static void clearRefreshToken() {
    html.window.localStorage.remove('refreshToken');
  }
}
