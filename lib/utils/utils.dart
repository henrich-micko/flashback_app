List getFirstN(List array, int n) {
  if (array.length < n) return array;
  return array.sublist(0, n-1);
}