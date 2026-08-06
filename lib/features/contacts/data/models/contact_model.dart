import '../../domain/entities/contacts_entity.dart';

class ContactsModel extends ContactsEntity {
  ContactsModel({
    required super.contactUserId,
    required super.firstName,
    required super.lastName,
    required super.avatarUrl,
    required super.isOnline,
    required super.lastSeenAt,
  });

  factory ContactsModel.fromEntity(ContactsEntity entity) {
    return ContactsModel(
      contactUserId: entity.contactUserId,
      firstName: entity.firstName,
      lastName: entity.lastName,
      avatarUrl: entity.avatarUrl,
      isOnline: entity.isOnline,
      lastSeenAt: entity.lastSeenAt,
    );
  }

  factory ContactsModel.fromJson(Map<String, dynamic> json) {
    return ContactsModel(
      contactUserId: json['contactUserId'] as String? ??
          json['contactsUserId'] as String? ??
          json['userId'] as String? ??
          json['id'] as String? ??
          '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] as String? ?? '',
    );
  }

  ContactsEntity get toEntity => ContactsEntity(
    contactUserId: contactUserId,
    firstName: firstName,
    lastName: lastName,
    avatarUrl: avatarUrl,
    isOnline: isOnline,
    lastSeenAt: lastSeenAt,
  );
}
