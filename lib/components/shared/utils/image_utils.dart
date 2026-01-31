import 'package:reliefflow_frontend_public_app/env.dart';

/// Utility class for image URL handling.
class ImageUtils {
  ImageUtils._();

  /// Converts a relative image URL to an absolute URL using the base URL.
  /// If the URL is already absolute (starts with http/https), returns as-is.
  ///
  /// Note: kBaseUrl includes '/api' but uploads are at root '/uploads',
  /// so we extract just the origin (scheme://host:port).
  static String getImageUrl(String url) {
    if (url.isEmpty) return '';

    if (url.startsWith('http') || url.startsWith('https')) {
      return url;
    }

    // kBaseUrl includes '/api' but uploads are at root '/uploads'
    // We need to use the origin (scheme://host:port)
    final uri = Uri.parse(kBaseUrl);
    final origin = '${uri.scheme}://${uri.host}:${uri.port}';

    if (url.startsWith('/')) {
      return '$origin$url';
    }
    return '$origin/$url';
  }
}
