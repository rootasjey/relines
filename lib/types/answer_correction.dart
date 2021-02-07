class AnswerCorrection {
  final String id;
  final String name;

  AnswerCorrection({this.id = '', this.name = ''});

  factory AnswerCorrection.fromJSON(Map<String, dynamic> data) {
    return AnswerCorrection(
      id: data['id'],
      name: data['name'],
    );
  }
}
