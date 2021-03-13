import 'package:relines/utils/date_helper.dart';

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

  factory PointInTime.fromJSON(Map<String, dynamic> data) {
    DateTime date = DateHelper.fromFirestore(data['original']);

    return PointInTime(
      beforeJC: data['beforeJC'] ?? false,
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      date: date,
    );
  }
}
