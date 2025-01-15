List getFirstN(List array, int n) {
  if (array.length < n) return array;
  return array.sublist(0, n-1);
}

String truncateWithEllipsis(String text, int maxChar) {
  if (text.length <= maxChar) {
    return text; // No truncation needed
  }
  return '${text.substring(0, maxChar)}...';
}