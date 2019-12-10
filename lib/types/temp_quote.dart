class TempQuote {
  final String id;
  final String name;
  final List<String> topics;

  TempQuote({this.id, this.name, this.topics});

  factory TempQuote.fromJSON(Map<String, dynamic> json) {
    List<String> topicsList = [];

    if (json['topics'] != null) {
      for (var tag in json['topics']) {
        topicsList.add(tag);
      }
    }

    return TempQuote(
      id: json['id'],
      name: json['name'],
      topics: topicsList,
    );
  }
}
