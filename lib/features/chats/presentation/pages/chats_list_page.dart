import 'package:chateo_app/core/domain/routing/app_routes_path.dart';
import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/presentation/widgets/app_search_bar.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/features/contacts/presentation/manager/contacts_bloc.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/generated/locale_keys.g.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../manager/chats_bloc.dart';
import '../widgets/chats_cell_widget.dart';
import '../widgets/create_chat_widget.dart';
import '../widgets/story_avatar_widget.dart';
import '../widgets/your_story_widget.dart';

class ChatsListPage extends StatefulWidget {
  const ChatsListPage({super.key});

  @override
  State<ChatsListPage> createState() => _ChatsListPageState();
}

class _ChatsListPageState extends State<ChatsListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final chatsState = context.read<ChatsBloc>().state;
    // Запрашиваем данные только если они ещё не загружены и не загружаются в данный момент
    if (chatsState is! ChatsLoaded && chatsState is! ChatsLoading) {
      context.read<ChatsBloc>().add(const LoadChatsRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<ChatsBloc>().add(const LoadChatsRequested());
    await context.read<ChatsBloc>().stream.firstWhere(
      (state) => state is ChatsLoaded || state is ChatsError,
    );
  }

  void _createChat() {
    final contactsBloc = context.read<ContactsBloc>();
    if (contactsBloc.state is! ContactsLoaded && contactsBloc.state is! ContactsLoading) {
      contactsBloc.add(const LoadContactsRequested());
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ChatsBloc>()),
          BlocProvider.value(value: context.read<ContactsBloc>()),
        ],
        child: const CreateChatWidget(),
      ),
    );
  }

  void _onSearchChanged(String query) {
    context.read<ChatsBloc>().add(SearchChatsRequested(query: query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ChatsBloc>().add(const SearchChatsRequested(query: ''));
  }

  @override
  Widget build(BuildContext context) {
    // Registers this widget as a dependent of EasyLocalization so it rebuilds on locale change.
    EasyLocalization.of(context);
    return BlocListener<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is ChatsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.chats_title.tr()),
          actions: [
            IconButton(
              onPressed: _createChat,
              icon: AppIcon(Assets.icons.messagePlusAlt),
            ),
            IconButton(onPressed: null, icon: AppIcon(Assets.icons.listCheck)),
          ],
        ),
        body: Column(
          children: [
            // ── Stories row ─────────────────────────────────────────────────
            _buildStoriesRow(context),

            // ── Divider ──────────────────────────────────────────────────────
            Divider(),

            // ── Search bar ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: AppSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),
            ),

            // ── Chat list ───────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<ChatsBloc, ChatsState>(
                builder: (context, state) {
                  if (state is ChatsInitial || state is ChatsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatsLoaded) {
                    final chats = state.displayChats;

                    if (chats.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppIcon(Assets.icons.messageCircle, size: 64),
                            SizedBox(height: 12.h),
                            Text(
                              state.isSearchMode
                                  ? LocaleKeys.search_no_results.tr(
                                      args: [state.searchQuery],
                                    )
                                  : LocaleKeys.search_no_chats.tr(),
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
                        padding: EdgeInsets.only(top: 4.h),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: chats.length,
                        separatorBuilder: (context, index) => Center(
                          child: SizedBox(width: 380.w, child: const Divider()),
                        ),
                        itemBuilder: (context, index) {
                          final c = chats[index];
                          return InkWell(
                            onTap: () => context.push(
                              AppRoutesPath.dialog,
                              extra: {
                                'chatId': c.chatId,
                                'chatName': c.chatName,
                                'chatAvatarUrl': c.chatAvatarUrl,
                                'isOnline': c.isOnline,
                              },
                            ),
                            child: ChatsCell(
                              username: c.chatName,
                              lastMessage: c.lastMessage.content,
                              avatarUrl: c.chatAvatarUrl,
                              isOnline: c.isOnline,
                              lastSeen: DateTime.tryParse(c.lastMessage.createdAt) ??
                                  DateTime.tryParse(c.createdAt),
                              unreadCount: c.unreadCount,
                            ),
                          );
                        },
                      ),
                    );
                  }

                  if (state is ChatsError) {
                    return Center(
                      child: Text(
                        LocaleKeys.chats_failed_to_load.tr(),
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

  Widget _buildStoriesRow(BuildContext context) {
    // Mock story data: first item is "Your Story", rest are contacts with stories
    final storyUsers = [
      _StoryData(username: 'Midala Hu...', avatarUrl: null, hasStory: true),
      _StoryData(username: 'Salsabila...', avatarUrl: null, hasStory: true),
    ];

    return SizedBox(
      height: 108.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        children: [
          // "Your Story" — add button
          YourStoryWidget(),
          SizedBox(width: 16.w),
          ...storyUsers.map(
            (s) => Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: StoryAvatarWidget(
                username: s.username,
                avatarUrl: s.avatarUrl,
                hasStory: s.hasStory,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Story data helper ─────────────────────────────────────────────────────────

class _StoryData {
  final String username;
  final String? avatarUrl;
  final bool hasStory;

  _StoryData({
    required this.username,
    required this.avatarUrl,
    required this.hasStory,
  });
}
