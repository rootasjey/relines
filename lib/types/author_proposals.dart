import 'package:disfigstyle/types/author.dart';

class AuthorProposals {
  final String type;
  final List<Author> values;

  AuthorProposals({
    this.type = 'author',
    this.values = const [],
  });

  factory AuthorProposals.fromJSON(Map<String, dynamic> data) {
    List<Author> authors = [];

    for (var rawAuthor in data['values']) {
      authors.add(Author.fromJSON(rawAuthor));
    }

    return AuthorProposals(
      type: data['type'],
      values: authors,
    );
  }
}
