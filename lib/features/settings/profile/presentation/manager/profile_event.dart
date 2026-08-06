part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileRequested extends ProfileEvent {
  const LoadProfileRequested();
}

/// Событие для нового пользователя: профиль ещё не создан на сервере.
/// Сразу переходим в состояние ProfileLoaded с пустыми данными.
class LoadProfileAsNewUserRequested extends ProfileEvent {
  const LoadProfileAsNewUserRequested();
}

class UpdateProfileRequested extends ProfileEvent {
  final ProfileEntity profileEntity;

  const UpdateProfileRequested({required this.profileEntity});

  @override
  List<Object?> get props => [profileEntity];
}

class UploadAvatarRequested extends ProfileEvent {
  final XFile xFile;

  const UploadAvatarRequested({required this.xFile});

  @override
  List<Object?> get props => [xFile.path];
}
