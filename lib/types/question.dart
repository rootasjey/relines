import 'package:relines/types/quote_question.dart';

class Question {
  final String guessType;
  final QuoteQuestion quote;

  Question({
    this.quote,
    this.guessType = '',
  });

  factory Question.fromJSON(Map<String, dynamic> data) {
    return Question(
      quote: QuoteQuestion.fromJSON(data['quote']),
      guessType: data['guessType'],
    );
  }
}
