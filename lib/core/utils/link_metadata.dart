import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fetches lightweight metadata (the page title) for a URL, so reference cards
/// can show what a link actually is instead of just its host.
///
/// Deliberately dependency-free (uses `dart:io`): it does a single GET, reads
/// only the document head, and parses `og:title` / `<title>` with cheap regex.
/// Everything is best-effort — any failure simply yields `null`.
class LinkMetadataService {
  const LinkMetadataService();

  static final RegExp _ogTitle = RegExp(
    r'''<meta[^>]+(?:property|name)\s*=\s*["']og:title["'][^>]*>''',
    caseSensitive: false,
  );
  static final RegExp _contentAttr = RegExp(
    r'''content\s*=\s*["']([^"']*)["']''',
    caseSensitive: false,
  );
  static final RegExp _titleTag = RegExp(
    r'<title[^>]*>(.*?)</title>',
    caseSensitive: false,
    dotAll: true,
  );

  /// Returns the page title for [url], or `null` if it can't be determined.
  Future<String?> fetchTitle(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;

    // YouTube pages are JS-rendered, so scraping og:title is flaky. Their
    // oEmbed endpoint returns the real video title (and channel) as JSON with
    // no API key — try that first for any YouTube link.
    if (_isYouTube(uri)) {
      final title = await _fetchOEmbedTitle(uri);
      if (title != null) return title;
    }

    HttpClient? client;
    try {
      client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5)
        ..userAgent =
            'Mozilla/5.0 (compatible; AwesomeMemo/1.0; +https://awesome.memo)';

      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'text/html');
      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );

      if (response.statusCode != HttpStatus.ok) return null;
      final contentType = response.headers.contentType?.mimeType ?? '';
      if (!contentType.contains('html')) return null;

      // Read at most ~64KB — the <head> (and thus the title) lives up front.
      final html = await _readCapped(response, 64 * 1024);
      return _extractTitle(html);
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  bool _isYouTube(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'youtu.be' ||
        host == 'youtube.com' ||
        host.endsWith('.youtube.com');
  }

  /// Resolves a YouTube video title via the keyless oEmbed endpoint. Returns
  /// `"<title> · <channel>"` when both are present, else just the title.
  Future<String?> _fetchOEmbedTitle(Uri videoUri) async {
    final endpoint = Uri.https('www.youtube.com', '/oembed', {
      'url': videoUri.toString(),
      'format': 'json',
    });
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(endpoint);
      final response = await request.close().timeout(
        const Duration(seconds: 6),
      );
      if (response.statusCode != HttpStatus.ok) return null;
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final title = _clean(json['title'] as String?);
      if (title == null) return null;
      final author = _clean(json['author_name'] as String?);
      return author == null ? title : '$title · $author';
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  Future<String> _readCapped(HttpClientResponse response, int maxBytes) async {
    final bytes = <int>[];
    await for (final chunk in response) {
      bytes.addAll(chunk);
      if (bytes.length >= maxBytes) break;
    }
    return utf8.decode(bytes.take(maxBytes).toList(), allowMalformed: true);
  }

  String? _extractTitle(String html) {
    final og = _ogTitle.firstMatch(html);
    if (og != null) {
      final content = _contentAttr.firstMatch(og.group(0)!)?.group(1);
      final cleaned = _clean(content);
      if (cleaned != null) return cleaned;
    }
    return _clean(_titleTag.firstMatch(html)?.group(1));
  }

  String? _clean(String? raw) {
    if (raw == null) return null;
    final unescaped = raw
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return unescaped.isEmpty ? null : unescaped;
  }
}

final linkMetadataServiceProvider = Provider<LinkMetadataService>(
  (ref) => const LinkMetadataService(),
);
