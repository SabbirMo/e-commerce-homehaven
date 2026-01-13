/// Utility functions for text handling
class TextUtils {
  /// Truncates text to show only first two words followed by ellipsis
  static String truncateToTwoWords(String text) {
    if (text.isEmpty) return '';

    final words = text.split(' ');
    if (words.length <= 2) return text;

    return '${words[0]} ${words[1]}...';
  }
}
