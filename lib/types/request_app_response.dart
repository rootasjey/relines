import 'package:disfigstyle/types/partial_user_app.dart';

class RequestAppResponse {
  final bool success;
  final PartialUserApp app;

  RequestAppResponse({this.success, this.app});

  factory RequestAppResponse.fromJSON(Map<String, dynamic> data) {
    return RequestAppResponse(
      success: data['success'] ?? false,
      app: PartialUserApp.fromJSON(data['app']),
    );
  }
}
