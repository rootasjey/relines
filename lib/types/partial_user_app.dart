import 'package:disfigstyle/types/partial_user.dart';

class PartialUserApp {
  final String id;
  final PartialUser user;

  PartialUserApp({this.id, this.user});

  factory PartialUserApp.fromJSON(Map<String, dynamic> data) {
    return PartialUserApp(
      id: data['id'] ?? '',
      user: PartialUser.fromJSON(data['user']),
    );
  }
}
