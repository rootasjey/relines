import 'package:relines/types/app_stats_calls.dart';

class AppStats {
  final int usedBy;
  final AppStatsCalls calls;

  AppStats({this.usedBy, this.calls});

  factory AppStats.fromJSON(Map<String, dynamic> data) {
    return AppStats(
      calls: AppStatsCalls.fromJSON(data['calls']),
      usedBy: data['usedBy'] ?? 0,
    );
  }
}
