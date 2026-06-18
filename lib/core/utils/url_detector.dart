/// Small helpers for detecting URLs inside free-form memo text.
///
/// Used as a cheap local heuristic (e.g. to bias classification toward a
/// "references" category, or to render link affordances) independent of the
/// LLM.
abstract final class UrlDetector {
  static final RegExp _urlRegExp = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  /// Whether [text] contains at least one http(s) URL.
  static bool hasUrl(String text) => _urlRegExp.hasMatch(text);

  /// Returns all http(s) URLs found in [text], in order.
  static List<String> extractUrls(String text) =>
      _urlRegExp.allMatches(text).map((m) => m.group(0)!).toList();

  /// The first URL found, or `null`.
  static String? firstUrl(String text) {
    final match = _urlRegExp.firstMatch(text);
    return match?.group(0);
  }

  /// A human-readable rendering of [url] for when no page title is available:
  /// drops the scheme, percent-decodes the path (so Korean/escaped slugs read
  /// naturally), and trims a trailing slash. Falls back to [url] on parse
  /// failure. e.g. `https://velog.io/@me/AI%EB%A1%9C-...` → `velog.io/@me/AI로-...`.
  static String pretty(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;

    final buffer = StringBuffer(uri.host)..write(uri.path);
    if (uri.hasQuery) buffer.write('?${uri.query}');

    var readable = buffer.toString();
    try {
      readable = Uri.decodeFull(readable);
    } catch (_) {
      // Keep the raw form if it isn't valid percent-encoding.
    }
    if (readable.endsWith('/')) {
      readable = readable.substring(0, readable.length - 1);
    }
    return readable;
  }
}
