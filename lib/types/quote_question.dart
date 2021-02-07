class QuoteQuestion {
  final String id;
  final String name;
  final List<String> topics;

  QuoteQuestion({
    this.id = '',
    this.name = '',
    this.topics = const [],
  });

  factory QuoteQuestion.fromJSON(Map<String, dynamic> data) {
    final _topics = <String>[];

    Map<String, dynamic> mapTopics = data['topics'];

    if (mapTopics != null) {
      mapTopics.forEach((key, value) {
        _topics.add(key);
      });
    }

    return QuoteQuestion(
      id: data['id'],
      name: data['name'],
      topics: _topics,
    );
  }
}
