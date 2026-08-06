import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.userId,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    required super.avatarUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      userId: map['userId'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String?,
    );
  }

  ProfileEntity get toEntity => ProfileEntity(
    userId: userId,
    phoneNumber: phoneNumber,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
  );
}
