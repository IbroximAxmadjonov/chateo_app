class ProfileEntity {
  final String userId;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String? avatarUrl;

  ProfileEntity({
    required this.userId,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.avatarUrl,
  });
}
