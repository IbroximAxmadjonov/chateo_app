import 'dart:async';
import 'dart:io' as io;

import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/features/settings/profile/domain/use_cases/put_profile_use_case.dart';
import 'package:chateo_app/features/settings/profile/domain/use_cases/upload_avatar_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/data_sources/profile_cache_service.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/use_cases/get_profile_use_case.dart';

part 'profile_event.dart';

part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final PutProfileUseCase putProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final ProfileCacheService cacheService;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.putProfileUseCase,
    required this.uploadAvatarUseCase,
    required this.cacheService,
  }) : super(const ProfileInitial()) {
    on<LoadProfileRequested>(_loadProfile);
    on<LoadProfileAsNewUserRequested>(_loadProfileAsNewUser);
    on<UpdateProfileRequested>(_updateProfile);
    on<UploadAvatarRequested>(_uploadAvatar);
  }

  // ── Load Profile ─────────────────────────────────────────────────────────

  /// Новый пользователь: профиль ещё не существует. Сразу показываем пустую форму.
  FutureOr<void> _loadProfileAsNewUser(
    LoadProfileAsNewUserRequested event,
    Emitter<ProfileState> emit,
  ) {
    emit(
      ProfileLoaded(
        profileEntity: ProfileEntity(
          userId: '',
          phoneNumber: '',
          firstName: '',
          lastName: '',
          avatarUrl: null,
        ),
      ),
    );
  }

  FutureOr<void> _loadProfile(
    LoadProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    // 1. Show cached data instantly (stale-while-revalidate)
    final cached = await cacheService.loadCached();
    if (cached != null) {
      emit(ProfileCacheLoaded(profileEntity: cached));
    } else {
      emit(const ProfileLoading());
    }

    // 2. Fetch fresh data from network
    final result = await getProfileUseCase(NoParams());

    result.fold(
      (l) {
        // Keep cached data visible on network error
        if (cached != null) {
          emit(ProfileLoaded(profileEntity: cached));
        } else {
          emit(ProfileError(message: l.message));
        }
      },
      (r) {
        final profile = ProfileEntity(
          userId: r.userId,
          phoneNumber: r.phoneNumber,
          firstName: r.firstName,
          lastName: r.lastName,
          avatarUrl: r.avatarUrl,
        );
        // 3. Persist fresh data to cache for next launch
        // ⚠️ тут нельзя async, поэтому делай так:
        cacheService.saveCache(profile).then((_) {
          if (!emit.isDone) {
            emit(ProfileLoaded(profileEntity: profile));
          }
        });
      },
    );
  }

  // ── Update Profile ───────────────────────────────────────────────────────

  FutureOr<void> _updateProfile(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileUpdating());

    final result = await putProfileUseCase(
      PutProfileUseCaseParams(
        firstName: event.profileEntity.firstName,
        lastName: event.profileEntity.lastName,
        avatarUrl: event.profileEntity.avatarUrl,
      ),
    );

    result.fold((l) => emit(ProfileError(message: l.message)), (r) async {
      // Also update the cache so next open shows updated name immediately
      await cacheService.saveCache(event.profileEntity);
      emit(ProfileUpdated(profileEntity: event.profileEntity));
    });
  }

  // ── Upload Avatar ────────────────────────────────────────────────────────

  FutureOr<void> _uploadAvatar(
    UploadAvatarRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const AvatarUploading());

    // Convert XFile → dart:io File
    final ioFile = io.File(event.xFile.path);

    final result = await uploadAvatarUseCase(UploadAvatarParams(file: ioFile));

    result.fold(
      (failure) => emit(ProfileError(message: failure.message)),
      (fileKey) => emit(AvatarUploaded(avatarKey: fileKey)),
    );
  }
}
