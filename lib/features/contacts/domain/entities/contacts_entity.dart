class ContactsEntity {
  final String contactUserId;
  final String firstName;
  final String lastName;
  final String avatarUrl;
  final bool isOnline;
  final String lastSeenAt;

  ContactsEntity({
    required this.contactUserId,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
    required this.isOnline,
    required this.lastSeenAt,
  });
  String get fullName => '$firstName $lastName'.trim();
}
