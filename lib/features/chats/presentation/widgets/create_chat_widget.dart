import 'package:chateo_app/core/domain/routing/routes.dart';
import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/presentation/widgets/app_search_bar.dart';
import 'package:chateo_app/core/presentation/widgets/cell.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/features/chats/presentation/manager/chats_bloc.dart';
import 'package:chateo_app/features/contacts/domain/entities/contacts_entity.dart';
import 'package:chateo_app/features/contacts/presentation/manager/contacts_bloc.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreateChatWidget extends StatefulWidget {
  const CreateChatWidget({super.key});

  @override
  State<CreateChatWidget> createState() => _CreateChatWidgetState();
}

class _CreateChatWidgetState extends State<CreateChatWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _onSelectContact(ContactsEntity contact) {
    final chatsBloc = context.read<ChatsBloc>();

    // 1. Запрашиваем создание приватного чата на бэкенде
    chatsBloc.add(CreatePrivateChatRequested(otherUserId: contact.contactUserId));

    // 2. Закрываем модальное окно
    Navigator.of(context).pop();

    // 3. Переходим на страницу диалога
    context.push(
      AppRoutes.dialog,
      extra: {
        'chatId': contact.contactUserId,
        'chatName': contact.fullName,
        'chatAvatarUrl': contact.avatarUrl,
        'isOnline': contact.isOnline,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),

          // ── Drag Handle ──────────────────────────────────────────────────
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.appColors.secondaryContainer,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Header (Title & Close) ───────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Start New Chat',
                  style: context.appTextStyle.headlineSmall?.copyWith(
                    color: context.appColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: AppIcon(Assets.icons.closeSmall, size: 20),
                ),
              ],
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: AppSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
          ),

          Divider(height: 1.h),

          // ── Contact List ────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<ContactsBloc, ContactsState>(
              builder: (context, state) {
                if (state is ContactsInitial || state is ContactsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ContactsLoaded) {
                  var contacts = state.displayContacts;

                  if (_searchQuery.isNotEmpty) {
                    contacts = contacts
                        .where((c) => c.fullName.toLowerCase().contains(_searchQuery))
                        .toList();
                  }

                  if (contacts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(Assets.icons.user, size: 48),
                          SizedBox(height: 12.h),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No contacts found'
                                : 'No contacts available',
                            style: context.appTextStyle.titleSmall?.copyWith(
                              color: context.appColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: contacts.length,
                    separatorBuilder: (context, index) => Center(
                      child: SizedBox(width: 327.w, child: const Divider()),
                    ),
                    itemBuilder: (context, index) {
                      final c = contacts[index];
                      final statusText = c.isOnline ? 'Online' : 'Offline';

                      return InkWell(
                        onTap: () => _onSelectContact(c),
                        child: Cell(
                          dataTitle: c.fullName,
                          dataDate: statusText,
                          dataUrlAvatar: c.avatarUrl,
                          isOnline: c.isOnline,
                        ),
                      );
                    },
                  );
                }

                if (state is ContactsError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: context.appTextStyle.titleSmall?.copyWith(
                        color: context.appColors.error,
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
