class ReferenceType {
  /// Primary type of this reference (e.g. Book, Film, Music, ...).
  String primary;

  /// Secondary type of this reference (e.g. Novel, Drama, Pop, ...).
  String secondary;

  ReferenceType({
    this.primary = '',
    this.secondary = '',
  });

  factory ReferenceType.fromJSON(Map<String, dynamic> data) {
    if (data == null) {
      return ReferenceType();
    }

    return ReferenceType(
      primary: data['primary'] ?? '',
      secondary: data['secondary'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> data = Map();

    data['primary'] = primary;
    data['secondary'] = secondary;

    return data;
  }
}
