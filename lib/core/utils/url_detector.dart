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
}
