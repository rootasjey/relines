class AppRights {
  final bool editUser;
  final bool manageAuthor;
  final bool manageQuote;
  final bool manageQuotidian;
  final bool manageReference;
  final bool proposeQuote;
  final bool readQuote;
  final bool readUser;
  final bool validateQuote;
  final bool services;

  AppRights({
    this.editUser = false,
    this.manageAuthor = false,
    this.manageQuote = false,
    this.manageQuotidian = false,
    this.manageReference = false,
    this.proposeQuote = false,
    this.readQuote = false,
    this.readUser = false,
    this.validateQuote = false,
    this.services = false,
  });

  factory AppRights.fromJSON(Map<String, dynamic> data) {
    return AppRights(
      editUser: data['api:editUser'],
      manageAuthor: data['api:manageAuthor'],
      manageQuote: data['api:manageQuote'],
      manageQuotidian: data['api:manageQuotidian'],
      manageReference: data['api:manageReference'],
      proposeQuote: data['api:proposeQuote'],
      readQuote: data['api:readQuote'],
      readUser: data['api:readUser'],
      validateQuote: data['api:validateQuote'],
      services: data['api:services'],
    );
  }
}
