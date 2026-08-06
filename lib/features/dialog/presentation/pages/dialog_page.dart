import 'package:chateo_app/core/presentation/widgets/app_icon.dart';
import 'package:chateo_app/core/utils/theme_extension.dart';
import 'package:chateo_app/core/utils/themes/app_colors.dart';
import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:chateo_app/features/dialog/presentation/manager/dialog_bloc.dart';
import 'package:chateo_app/features/dialog/presentation/widgets/message_bubble_widget.dart';
import 'package:chateo_app/generated/assets.dart';
import 'package:chateo_app/core/data/storage/auth_storage.dart';
import 'package:chateo_app/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogPage extends StatefulWidget {
  const DialogPage({
    super.key,
    required this.chatId,
    required this.chatName,
    this.chatAvatarUrl,
    this.isOnline = false,
    // The currently logged-in user's id to decide which bubble side to show.
    this.currentUserId = '',
  });

  final String chatId;
  final String chatName;
  final String? chatAvatarUrl;
  final bool isOnline;
  final String currentUserId;

  @override
  State<DialogPage> createState() => _DialogPageState();
}

class _DialogPageState extends State<DialogPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    context
        .read<DialogBloc>()
        .add(LoadMessagesRequested(chatId: widget.chatId));
  }

  // Pagination: load more when scrolled to top (ListView is reversed)
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<DialogBloc>().state;
      if (state is DialogLoaded && state.hasMore && !_isSearchMode) {
        final oldest = state.messages.last;
        context.read<DialogBloc>().add(
              LoadMessagesRequested(
                chatId: widget.chatId,
                before: oldest.createdAt.toUtc().toIso8601String(),
                isLoadMore: true,
              ),
            );
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    context.read<DialogBloc>().add(
          SendMessageRequested(
            chatId: widget.chatId,
            type: 1,
            content: text,
          ),
        );
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _searchController.clear();
        context.read<DialogBloc>().add(const ClearSearchRequested());
      }
    });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      context.read<DialogBloc>().add(const ClearSearchRequested());
      return;
    }
    context.read<DialogBloc>().add(
          SearchMessagesRequested(chatId: widget.chatId, query: query),
        );
  }

  // Mark last visible message as read
  void _markLastRead(List<DialogEntity> messages) {
    if (messages.isEmpty) return;
    // The latest message is at index 0 (list is reversed)
    final latest = messages.first;
    if (latest.senderId != widget.currentUserId && latest.myStatus == 0) {
      context.read<DialogBloc>().add(
            MarkReadRequested(
              chatId: widget.chatId,
              upToMessageId: latest.messageId,
            ),
          );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DialogBloc, DialogState>(
      listener: (context, state) {
        if (state is DialogError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.appColors.error,
            ),
          );
        }
        if (state is DialogLoaded) {
          _markLastRead(state.messages);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.appColors.surface,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              // ── Search bar (only in search mode) ───────────────────────
              if (_isSearchMode) _buildSearchBar(context),

              // ── Messages list ───────────────────────────────────────────
              Expanded(child: _buildBody(context, state)),

              // ── Input field ─────────────────────────────────────────────
              _buildInputField(context, state),
            ],
          ),
        );
      },
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.appColors.surface,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: AppIcon(Assets.icons.chevronLeft),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Avatar
          _buildAvatar(context, size: 36),
          SizedBox(width: 10.w),
          // Name + online status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: context.appTextStyle.headlineSmall?.copyWith(
                    color: context.appColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.isOnline)
                  Text(
                    'Online',
                    style: context.appTextStyle.bodyMedium?.copyWith(
                      color: AccentColor.success,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Search toggle
        IconButton(
          onPressed: _toggleSearch,
          icon: AppIcon(
            Assets.icons.search,
            color: _isSearchMode
                ? context.appColors.primary
                : context.appColors.secondary,
          ),
        ),
        // More menu
        IconButton(
          onPressed: () {},
          icon: AppIcon(Assets.icons.hamburger),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      color: context.appColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        autofocus: true,
        style: context.appTextStyle.titleSmall,
        decoration: InputDecoration(
          hintText: 'Search in conversation...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(10.r),
            child: AppIcon(Assets.icons.search, size: 18),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: AppIcon(Assets.icons.closeSmall, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DialogBloc>().add(const ClearSearchRequested());
                  },
                )
              : null,
        ),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, DialogState state) {
    if (state is DialogLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DialogLoaded) {
      // In search mode, show search results
      final items =
          state.isSearchMode ? state.searchResults : state.messages;

      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(Assets.icons.messageCircle, size: 64),
              SizedBox(height: 12.h),
              Text(
                state.isSearchMode
                    ? 'No messages found'
                    : 'No messages yet.\nSay hello! 👋',
                textAlign: TextAlign.center,
                style: context.appTextStyle.titleSmall?.copyWith(
                  color: context.appColors.onSurface,
                ),
              ),
            ],
          ),
        );
      }

      return _buildMessageList(context, state, items);
    }

    if (state is DialogError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: context.appColors.error, size: 48.r),
            SizedBox(height: 12.h),
            Text(
              state.message,
              style: context.appTextStyle.titleSmall
                  ?.copyWith(color: context.appColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadMessages,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMessageList(
    BuildContext context,
    DialogLoaded state,
    List<DialogEntity> items,
  ) {
    // Build a flat list with date separators inserted
    final listItems = _buildListItemsWithDates(items);

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: listItems.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Load-more indicator at the end (top of chat)
        if (index == listItems.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final item = listItems[index];
        if (item is _DateLabel) {
          return DateSeparatorWidget(date: item.date);
        }

        final msg = item as DialogEntity;
        final myUserId = widget.currentUserId.isNotEmpty
            ? widget.currentUserId
            : (sl<AuthStorage>().getUserId() ?? '');

        final isMe = (myUserId.isNotEmpty && msg.senderId == myUserId) ||
            (msg.myStatus >= 0 && msg.senderFirstName.isEmpty);
        // Find replyTo
        DialogEntity? replyTo;
        if (msg.replyToMessageId != null &&
            msg.replyToMessageId!.isNotEmpty) {
          try {
            replyTo = state.messages.firstWhere(
                (m) => m.messageId == msg.replyToMessageId);
          } catch (_) {}
        }

        return MessageBubbleWidget(
          message: msg,
          isMe: isMe,
          replyToMessage: replyTo,
        );
      },
    );
  }

  /// Inserts [_DateLabel] items between messages on different calendar days.
  /// Result list is ordered newest-first so [ListView.builder(reverse: true)]
  /// renders the newest message at the bottom and oldest at the top with date headers.
  List<dynamic> _buildListItemsWithDates(List<DialogEntity> items) {
    final result = <dynamic>[];
    if (items.isEmpty) return result;

    // Ensure items are sorted newest-first
    final sortedItems = List<DialogEntity>.from(items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (int i = 0; i < sortedItems.length; i++) {
      final msg = sortedItems[i];
      result.add(msg);

      final currentDay = DateTime(
        msg.createdAt.year,
        msg.createdAt.month,
        msg.createdAt.day,
      );

      final isOldestInList = (i == sortedItems.length - 1);
      final nextMsg = isOldestInList ? null : sortedItems[i + 1];
      final nextDay = nextMsg != null
          ? DateTime(
              nextMsg.createdAt.year,
              nextMsg.createdAt.month,
              nextMsg.createdAt.day,
            )
          : null;

      // Insert date label after the oldest message of the day
      // so in reverse ListView it appears ABOVE the day's messages
      if (isOldestInList || currentDay != nextDay) {
        result.add(_DateLabel(currentDay));
      }
    }
    return result;
  }

  // ── Input field ─────────────────────────────────────────────────────────────

  Widget _buildInputField(BuildContext context, DialogState state) {
    final isSending = state is DialogLoaded && state.isSending;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          border: Border(
            top: BorderSide(
              color: context.appColors.onSurfaceVariant,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Attach button
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: context.appColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: AppIcon(Assets.icons.plus, size: 18),
                onPressed: () {},
              ),
            ),
            SizedBox(width: 12.w),

            // Text input
            Expanded(
              child: TextField(
                controller: _messageController,
                onChanged: (_) => setState(() {}),
                style: context.appTextStyle.titleSmall,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.appColors.surfaceContainer,
                ),
              ),
            ),
            SizedBox(width: 12.w),

            // Send button
            GestureDetector(
              onTap: isSending ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: _messageController.text.trim().isNotEmpty && !isSending
                      ? context.appColors.primary
                      : context.appColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? Padding(
                        padding: EdgeInsets.all(10.r),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.appColors.onPrimary,
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(10.r),
                        child: AppIcon(
                          Assets.icons.sendAltFilled,
                          size: 22,
                          color: _messageController.text.trim().isNotEmpty
                              ? context.appColors.onPrimary
                              : context.appColors.onSurface,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar ──────────────────────────────────────────────────────────────────

  Widget _buildAvatar(BuildContext context, {double size = 48}) {
    Widget avatarContent;
    if (widget.chatAvatarUrl != null && widget.chatAvatarUrl!.isNotEmpty) {
      avatarContent = Image.network(
        widget.chatAvatarUrl!,
        width: size.w,
        height: size.h,
        fit: BoxFit.cover,
        errorBuilder: (ctx, e, s) => _buildInitials(context, size),
      );
    } else {
      avatarContent = _buildInitials(context, size);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular((size * 0.35).r),
          child: SizedBox(
              width: size.w, height: size.h, child: avatarContent),
        ),
        if (widget.isOnline)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 11.r,
              height: 11.r,
              decoration: BoxDecoration(
                color: AccentColor.success,
                shape: BoxShape.circle,
                border: Border.all(
                    color: context.appColors.surface, width: 2.r),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials(BuildContext context, double size) {
    final initials = _getInitials(widget.chatName);
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: context.appColors.primary,
        borderRadius: BorderRadius.circular((size * 0.35).r),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: context.appTextStyle.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: (size * 0.38).sp,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }
}

// ── Private helpers ────────────────────────────────────────────────────────────

class _DateLabel {
  final DateTime date;
  const _DateLabel(this.date);
}
