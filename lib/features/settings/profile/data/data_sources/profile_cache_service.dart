import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/profile_entity.dart';

/// Caches the last known profile locally so the UI can show real data
/// instantly while the network request is still in flight.
class ProfileCacheService {
  static const String _key = 'cached_profile';

  Future<ProfileEntity?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return ProfileEntity(
        userId: map['userId'] as String? ?? '',
        phoneNumber: map['phoneNumber'] as String? ?? '',
        firstName: map['firstName'] as String? ?? '',
        lastName: map['lastName'] as String? ?? '',
        avatarUrl: map['avatarUrl'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCache(ProfileEntity profile) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'userId': profile.userId,
      'phoneNumber': profile.phoneNumber,
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      'avatarUrl': profile.avatarUrl,
    };
    await prefs.setString(_key, json.encode(map));
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
