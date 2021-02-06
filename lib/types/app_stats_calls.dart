class AppStatsCalls {
  final int allTime;
  final int callsLimit;

  AppStatsCalls({this.allTime, this.callsLimit});

  factory AppStatsCalls.fromJSON(Map<String, dynamic> data) {
    return AppStatsCalls(
      allTime: data['allTime'],
      callsLimit: data['limit'],
    );
  }
}
