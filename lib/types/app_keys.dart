class AppKeys {
  String primary;
  String secondary;

  AppKeys({
    this.primary = '',
    this.secondary = '',
  });

  factory AppKeys.fromJSON(Map<String, dynamic> data) {
    return AppKeys(
      primary: data['primary'] ?? '',
      secondary: data['secondary'] ?? '',
    );
  }
}
