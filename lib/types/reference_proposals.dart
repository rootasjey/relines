import 'package:disfigstyle/types/reference.dart';

class ReferenceProposals {
  final String type;
  final List<Reference> values;

  ReferenceProposals({
    this.type = 'author',
    this.values = const [],
  });

  factory ReferenceProposals.fromJSON(Map<String, dynamic> data) {
    List<Reference> references = [];

    for (var rawRef in data['values']) {
      references.add(Reference.fromJSON(rawRef));
    }

    return ReferenceProposals(
      type: data['type'],
      values: references,
    );
  }
}
