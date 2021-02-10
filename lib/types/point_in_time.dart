class PointInTime {
  bool beforeJC;
  String country;
  String city;
  DateTime date;

  PointInTime({
    this.city = '',
    this.country = '',
    this.date,
    this.beforeJC = false,
  });

  factory PointInTime.fromJSON(Map<String, dynamic> json) {
    var date = DateTime.now();

    if (json['date'] != null) {
      if (json['date']['_seconds'] != null) {
        date = DateTime.fromMillisecondsSinceEpoch(
            json['date']['_seconds'] * 1000);
      } else {
        date = (json['date']).toDate();
      }
    }

    return PointInTime(
      beforeJC: json['beforeJC'],
      country: json['country'],
      city: json['city'],
      date: date,
    );
  }
}
