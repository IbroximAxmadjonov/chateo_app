import 'package:chateo_app/core/presentation/widgets/app_icon.dart';

import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/profile_entity.dart';
import '../manager/profile_bloc.dart';
import '../widgets/profile_avatar_widget.dart';

class ProfilePage extends StatefulWidget {
  /// true — пользователь только что зарегистрировался (профиля ещё нет на сервере)
  final bool isNewUser;

  const ProfilePage({super.key, this.isNewUser = false});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  /// Флаг: данные с сервера уже вставлены (не перезаписывать при повторных emit)
  bool _initialized = false;

  /// fileKey полученный после успешной загрузки аватара в хранилище
  String? _pendingAvatarKey;

  @override
  void initState() {
    super.initState();

    if (widget.isNewUser) {
      // Новый пользователь — профиля на сервере ещё нет.
      // Сразу показываем пустую форму без сетевого запроса.
      context.read<ProfileBloc>().add(
        const LoadProfileAsNewUserRequested(),
      );
      return;
    }

    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _fillFrom(state.profileEntity);
    } else if (state is ProfileCacheLoaded) {
      _fillFrom(state.profileEntity);
    } else if (state is ProfileUpdated) {
      _fillFrom(state.profileEntity);
    } else {
      context.read<ProfileBloc>().add(const LoadProfileRequested());
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _fillFrom(ProfileEntity entity) {
    if (_initialized) return;
    _initialized = true;
    _firstNameController.text = entity.firstName;
    _lastNameController.text = entity.lastName;
  }

  void _onSave() {
    final state = context.read<ProfileBloc>().state;
    String phoneNumber = '';
    String? currentAvatarUrl;
    if (state is ProfileLoaded) {
      phoneNumber = state.profileEntity.phoneNumber;
      currentAvatarUrl = state.profileEntity.avatarUrl;
    } else if (state is ProfileCacheLoaded) {
      phoneNumber = state.profileEntity.phoneNumber;
      currentAvatarUrl = state.profileEntity.avatarUrl;
    } else if (state is ProfileUpdated) {
      phoneNumber = state.profileEntity.phoneNumber;
      currentAvatarUrl = state.profileEntity.avatarUrl;
    }
    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        profileEntity: ProfileEntity(
          userId: '',
          phoneNumber: phoneNumber,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          // Use newly uploaded key if available, otherwise keep current
          avatarUrl: _pendingAvatarKey ?? currentAvatarUrl,
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final textStyle = context.appTextStyle;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) _fillFrom(state.profileEntity);
        if (state is ProfileCacheLoaded) _fillFrom(state.profileEntity);

        if (state is AvatarUploaded) {
          // Store the fileKey — will be sent to backend when user taps Save
          setState(() => _pendingAvatarKey = state.avatarKey);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Фото загружено. Нажмите «Сохранить»'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        if (state is ProfileUpdated) {
          _initialized = false;
          _pendingAvatarKey = null;
          _fillFrom(state.profileEntity);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Профиль сохранён'),
              backgroundColor: AccentColor.success,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          context.pop();
        }

        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AccentColor.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading spinner only on true initial load (no cache available)
        final isLoading = state is ProfileLoading;
        final isSaving = state is ProfileUpdating;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: AppIcon(Assets.icons.chevronLeft),
            ),
            title: Text(LocaleKeys.more_profileAccount.tr()),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Scrollable content ─────────────────────────────────────
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.translucent,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isLoading)
                            Center(child: const CircularProgressIndicator())
                          else ...[
                            SizedBox(height: 32.h),

                            // ── Avatar ────────────────────────────────────────
                            ProfileAvatarWidget(),

                            SizedBox(height: 36.h),

                            // ── First Name ──────────────────────────────────
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.more_profileElement_firstName
                                    .tr(),
                              ),
                            ),

                            SizedBox(height: 8.h),

                            // ── Last Name ───────────────────────────────────
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                hintText: LocaleKeys.more_profileElement_lastName
                                    .tr(),
                              ),
                            ),

                            SizedBox(height: 36.h),

                            // ── Save button ─────────────────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    (_firstNameController.text.trim().isNotEmpty &&
                                        !isSaving)
                                    ? _onSave
                                    : null,
                                child: isSaving
                                    ? SizedBox(
                                        height: 20.h,
                                        width: 20.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        LocaleKeys.save.tr(),
                                        style: textStyle.headlineSmall,
                                      ),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
