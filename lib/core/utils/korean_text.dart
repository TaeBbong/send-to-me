/// Text helpers for Korean (and mixed CJK) typography.
library;

final _hangul = RegExp(r'[가-힣ㄱ-ㅎㅏ-ㅣ]');

/// Applies CSS `word-break: keep-all` semantics to Korean words: a word
/// containing Hangul wraps only at its spaces, never inside the word (어절).
///
/// Flutter's default line breaker treats every Hangul syllable as a valid
/// break point, so an auto-wrapped Korean sentence often drops one or two stray
/// characters onto the next line. Inserting a WORD JOINER (U+2060) between the
/// characters of a Korean word makes it an unbreakable unit, so breaks only
/// happen at the spaces between words — exactly like `keep-all`.
///
/// Only Korean words are touched: pure ASCII/number/URL tokens keep their
/// normal break behavior, so a long link can still wrap and won't overflow the
/// line. Words longer than [maxJoin] characters are also left breakable as a
/// safety net. Existing spaces and explicit `\n` line breaks are preserved.
String keepAll(String text, {int maxJoin = 20}) {
  final wordJoiner = String.fromCharCode(0x2060);
  String joinWord(String word) {
    if (!_hangul.hasMatch(word)) return word; // not Korean → leave as-is
    if (word.runes.length > maxJoin) return word; // keep long tokens breakable
    return word.runes.map(String.fromCharCode).join(wordJoiner);
  }

  return text
      .split('\n')
      .map((line) => line.split(' ').map(joinWord).join(' '))
      .join('\n');
}
