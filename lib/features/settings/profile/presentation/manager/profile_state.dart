part of 'profile_bloc.dart';

sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  // Optionally carry last-known cached profile so UI can show it while loading
  final ProfileEntity? cachedProfile;
  const ProfileLoading({this.cachedProfile});
}

/// Emitted instantly from local cache before network response arrives
class ProfileCacheLoaded extends ProfileState {
  final ProfileEntity profileEntity;
  const ProfileCacheLoaded({required this.profileEntity});
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profileEntity;

  const ProfileLoaded({required this.profileEntity});
}

class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

class ProfileUpdated extends ProfileState {
  final ProfileEntity profileEntity;

  const ProfileUpdated({required this.profileEntity});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}

/// Avatar is currently being uploaded to S3
class AvatarUploading extends ProfileState {
  /// Upload progress 0.0 – 1.0, or null if unknown
  final double? progress;
  const AvatarUploading({this.progress});
}

/// Avatar uploaded successfully; avatarKey is the fileKey from storage
class AvatarUploaded extends ProfileState {
  final String avatarKey;
  const AvatarUploaded({required this.avatarKey});
}

