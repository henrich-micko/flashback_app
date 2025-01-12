import 'package:flashbacks/utils/api/client.dart';

class Pagination<T> {
  final String? next;
  final String? previous;
  final List<T> results;
  final ItemFromJson<T> itemParser;

  const Pagination({
    required this.next,
    required this.previous,
    required this.results,
    required this.itemParser
  });

  static fromJson<T>(JsonData data, ItemFromJson<T> itemParser) {
    return Pagination<T>(
      next: data["next"],
      previous: data["previous"],
      results: List.from(data["results"].map((item) => itemParser(item))),
      itemParser: itemParser,
    );
  }
}