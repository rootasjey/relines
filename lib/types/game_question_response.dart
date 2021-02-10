import 'package:disfigstyle/types/author_proposals.dart';
import 'package:disfigstyle/types/enums.dart';
import 'package:disfigstyle/types/question.dart';
import 'package:disfigstyle/types/reference_proposals.dart';

class GameQuestionResponse {
  final Question question;
  final AuthorProposals authorProposals;
  final ReferenceProposals referenceProposals;
  final QuestionType type;

  GameQuestionResponse({
    this.question,
    this.authorProposals,
    this.referenceProposals,
    this.type = QuestionType.author,
  });

  factory GameQuestionResponse.fromJSON(Map<String, dynamic> data) {
    final String _type = data['proposals']['type'];

    AuthorProposals _authorProposals;
    if (_type == 'author') {
      _authorProposals = AuthorProposals.fromJSON(data['proposals']);
      _authorProposals.values.shuffle();
    }

    ReferenceProposals _referenceProposals;
    if (_type == 'reference') {
      _referenceProposals = ReferenceProposals.fromJSON(data['proposals']);
      _referenceProposals.values.shuffle();
    }

    return GameQuestionResponse(
      question: Question.fromJSON(data['question']),
      type: _type == 'author' ? QuestionType.author : QuestionType.reference,
      authorProposals: _authorProposals,
      referenceProposals: _referenceProposals,
    );
  }
}
