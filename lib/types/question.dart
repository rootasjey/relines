import 'package:relines/types/quote.dart';

class Question {
  final String guessType;
  final Quote quote;

  Question({
    this.quote,
    this.guessType = '',
  });

  factory Question.fromJSON(Map<String, dynamic> data) {
    return Question(
      quote: Quote.fromJSON(data['quote']),
      guessType: data['guessType'],
    );
  }
}
