import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/presentation/widgets/app_search_bar.dart';
import 'package:chateo_app/core/presentation/widgets/cell.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/routing/app_routes_path.dart';

import '../../../chats/presentation/manager/chats_bloc.dart';
import '../manager/contacts_bloc.dart';
import '../widgets/put_contact_widget.dart';

class ContactsListPage extends StatefulWidget {
  const ContactsListPage({super.key});

  @override
  State<ContactsListPage> createState() => _ContactsListPageState();
}

class _ContactsListPageState extends State<ContactsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<ContactsBloc>().state;
    if (state is! ContactsLoaded && state is! ContactsLoading) {
      context.read<ContactsBloc>().add(const LoadContactsRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<ContactsBloc>().add(const LoadContactsRequested());
    await context.read<ContactsBloc>().stream.firstWhere(
      (state) => state is ContactsLoaded || state is ContactsError,
    );
  }

  void _onSearchChanged(String query) {
    context.read<ContactsBloc>().add(SearchContactsRequested(query: query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ContactsBloc>().add(const SearchContactsRequested(query: ''));
  }

  void _putContact() {
    final contactsBloc = context.read<ContactsBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BlocProvider.value(value: contactsBloc, child: const PutContactWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Registers this widget as a dependent of EasyLocalization so it rebuilds on locale change.
    EasyLocalization.of(context);
    return BlocListener<ContactsBloc, ContactsState>(
      listener: (context, state) {
        if (state is ContactsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.contacts_title.tr()),
          actions: [
            IconButton(onPressed: _putContact, icon: AppIcon(Assets.icons.plus)),
          ],
        ),
        body: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: AppSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),
            ),

            // ── Contact list ────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ContactsBloc, ContactsState>(
                builder: (context, state) {
                  if (state is ContactsInitial || state is ContactsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ContactsLoaded) {
                    final contacts = state.displayContacts;

                    if (contacts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(Assets.icons.user, size: 64),
                            SizedBox(height: 12.h),
                            Text(
                              state.isSearchMode
                                  ? LocaleKeys.search_no_results.tr(
                                      args: [state.searchQuery],
                                    )
                                  : LocaleKeys.search_no_contacts.tr(),
                              style: context.appTextStyle.titleSmall?.copyWith(
                                color: context.appColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView.separated(
                        padding: EdgeInsets.only(top: 8.h),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: contacts.length,
                        separatorBuilder: (context, index) => Center(
                          child: SizedBox(width: 327.w, child: const Divider()),
                        ),
                        itemBuilder: (context, index) {
                          final c = contacts[index];
                          final statusText = c.isOnline
                              ? LocaleKeys.chats_online.tr()
                              : _formatLastSeen(context, c.lastSeenAt);
                          return InkWell(
                            onTap: () {
                              // Попытка найти существующий chatId для данного контакта из ChatsBloc
                              String resolvedChatId = '';
                              try {
                                final chatsState = context.read<ChatsBloc>().state;
                                if (chatsState is ChatsLoaded) {
                                  final matchingChat = chatsState.chats.firstWhere(
                                    (chat) =>
                                        chat.chatName.toLowerCase() ==
                                        c.fullName.toLowerCase(),
                                  );
                                  resolvedChatId = matchingChat.chatId;
                                }
                              } catch (_) {}

                              context.push(
                                AppRoutesPath.dialog,
                                extra: {
                                  'chatId': resolvedChatId,
                                  'chatName': c.fullName,
                                  'chatAvatarUrl': c.avatarUrl,
                                  'isOnline': c.isOnline,
                                },
                              );
                            },
                            child: Cell(
                              dataTitle: c.fullName,
                              dataDate: statusText,
                              dataUrlAvatar: c.avatarUrl,
                              isOnline: c.isOnline,
                              hasStory: index == 2 || index == 5,
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is ContactsError) {
                    return Center(
                      child: Text(
                        LocaleKeys.contacts_failed_to_load.tr(),
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
      ),
    );
  }

  String _formatLastSeen(BuildContext context, String rawDateTime) {
    if (rawDateTime.isEmpty) return '';
    try {
      final now = DateTime.now();
      final lastSeen = DateTime.parse(rawDateTime).toLocal();
      final diff = now.difference(lastSeen);

      if (diff.inMinutes < 1) {
        return LocaleKeys.chats_lastSeenJustNow.tr();
      } else if (diff.inMinutes < 60) {
        return LocaleKeys.chats_lastSeenMinutes.tr(
          args: [diff.inMinutes.toString()],
        );
      } else if (diff.inHours < 24) {
        return LocaleKeys.chats_lastSeenHours.tr(args: [diff.inHours.toString()]);
      } else if (diff.inDays == 1 ||
          (now.day - lastSeen.day == 1 &&
              now.month == lastSeen.month &&
              now.year == lastSeen.year)) {
        return LocaleKeys.chats_lastSeenYesterday.tr();
      } else {
        final dayStr = lastSeen.day.toString().padLeft(2, '0');
        final monthStr = lastSeen.month.toString().padLeft(2, '0');
        return '$dayStr.$monthStr.${lastSeen.year}';
      }
    } catch (_) {
      return rawDateTime;
    }
  }
}
