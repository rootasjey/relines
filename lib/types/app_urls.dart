class AppUrls {
  final String email;
  final String image;
  final String privacy;
  final String website;

  AppUrls({
    this.email = '',
    this.image = '',
    this.privacy = '',
    this.website = '',
  });

  factory AppUrls.fromJSON(Map<String, dynamic> data) {
    return AppUrls(
      email: data['email'],
      image: data['image'],
      privacy: data['privacy'],
      website: data['website'],
    );
  }
}
