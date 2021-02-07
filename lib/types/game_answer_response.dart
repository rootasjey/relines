import 'package:disfigstyle/types/answer_correction.dart';
import 'package:disfigstyle/types/question.dart';

class GameAnswerResponse {
  final Question question;
  final bool isCorrect;
  final String answerProposalId;
  final AnswerCorrection correction;

  GameAnswerResponse({
    this.question,
    this.answerProposalId = '',
    this.correction,
    this.isCorrect = false,
  });

  factory GameAnswerResponse.fromJSON(Map<String, dynamic> data) {
    return GameAnswerResponse(
      isCorrect: data['isCorrect'],
      answerProposalId: data['answerProposalId'],
      correction: AnswerCorrection.fromJSON(data['correction']),
      question: Question.fromJSON(data['question']),
    );
  }
}
