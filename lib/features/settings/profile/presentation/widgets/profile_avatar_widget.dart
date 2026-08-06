import 'dart:io';

import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../manager/profile_bloc.dart';

class ProfileAvatarWidget extends StatefulWidget {
  const ProfileAvatarWidget({super.key});

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  File? _pickedFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: context.appColors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: context.appColors.primary,
                ),
                title: Text('Сделать фото', style: context.appTextStyle.bodyLarge),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFrom(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: context.appColors.primary,
                ),
                title: Text(
                  'Выбрать из галереи',
                  style: context.appTextStyle.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFrom(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFrom(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked == null) return;

    setState(() => _pickedFile = File(picked.path));

    if (mounted) {
      context.read<ProfileBloc>().add(UploadAvatarRequested(xFile: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (_, s) => s is AvatarUploaded || s is ProfileError,
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка загрузки: ${state.message}'),
              backgroundColor: AccentColor.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        // Determine the current avatar URL from profile state
        String? networkAvatarUrl;
        if (state is ProfileLoaded) {
          networkAvatarUrl = state.profileEntity.avatarUrl;
        } else if (state is ProfileCacheLoaded) {
          networkAvatarUrl = state.profileEntity.avatarUrl;
        } else if (state is ProfileUpdated) {
          networkAvatarUrl = state.profileEntity.avatarUrl;
        }

        final isUploading = state is AvatarUploading;

        ImageProvider? imageProvider;
        if (_pickedFile != null) {
          imageProvider = FileImage(_pickedFile!);
        } else if (networkAvatarUrl != null && networkAvatarUrl.isNotEmpty) {
          imageProvider = NetworkImage(networkAvatarUrl);
        }

        return GestureDetector(
          onTap: isUploading ? null : _pickImage,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar circle
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.onSurfaceVariant.withValues(alpha: 0.15),
                  image: imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null,
                ),
                child: imageProvider == null
                    ? Center(child: AppIcon(Assets.icons.user, size: 56))
                    : null,
              ),

              // Upload progress overlay
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              // Edit badge (hidden while uploading)
              if (!isUploading)
                Positioned(
                  right: -2.w,
                  bottom: -2.h,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: context.appColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.appColors.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
