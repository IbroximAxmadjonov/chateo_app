import 'package:chateo_app/features/auth/presentation/pages/send_otp_page.dart';
import 'package:chateo_app/features/dialog/presentation/manager/dialog_bloc.dart';
import 'package:chateo_app/features/dialog/presentation/pages/dialog_page.dart';
import 'package:chateo_app/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:chateo_app/features/auth/presentation/pages/walk_through_page.dart';
import 'package:chateo_app/features/chats/presentation/pages/chats_list_page.dart';
import 'package:chateo_app/features/contacts/presentation/pages/contacts_list_page.dart';
import 'package:chateo_app/features/more/presentation/pages/more_list_page.dart';
import 'package:chateo_app/features/settings/account/presentation/pages/account_page.dart';
import 'package:chateo_app/features/settings/appereance/presentation/pages/appereance_page.dart';
import 'package:chateo_app/features/settings/data_usage/presentation/pages/data_usage_page.dart' show DataUsagePage;
import 'package:chateo_app/features/settings/help/presentation/pages/help_page.dart';
import 'package:chateo_app/features/settings/invite_your_friends/presentation/pages/invite_your_friends_page.dart';
import 'package:chateo_app/features/settings/notification/presentation/pages/notification_page.dart';
import 'package:chateo_app/features/settings/privacy/presentation/pages/privacy_page.dart';
import 'package:chateo_app/features/settings/profile/presentation/pages/profile_page.dart';
import 'package:chateo_app/features/settings/setting_chats/presentation/pages/setting_chats_page.dart';
import 'package:chateo_app/features/splash/presentation/pages/splash_page.dart';
import 'package:chateo_app/core/data/storage/auth_storage.dart';
import 'package:chateo_app/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


import 'navigation_page.dart';
import 'routes.dart';

final GoRouter router = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    /// Splash
    GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashPage()),

    /// Auth
    GoRoute(
      path: AppRoutes.walkThrough,
      builder: (context, state) => const WalkThrough(),
    ),
    GoRoute(
      path: AppRoutes.sentOtp,
      builder: (context, state) => const SendOtpPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyOtp,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        final phoneNumber = data['phoneNumber'] as String;
        final maskPhoneNumber = data['maskPhoneNumber'] as String;
        return VerifyOtpPage(
          phoneNumber: phoneNumber,
          maskPhoneNumber: maskPhoneNumber,
        );
      },
    ),

    /// Navigation - Home
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          NavigationPage(navigationShell: navigationShell),
      branches: [
        /// ContactsPage
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.contacts,
              builder: (context, state) => const ContactsListPage(),
            ),
          ],
        ),

        /// ChatsPage
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.chats,
              builder: (context, state) => const ChatsListPage(),
            ),
          ],
        ),

        /// MorePage
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.more,
              builder: (context, state) => const MoreListPage(),
            ),
          ],
        ),
      ],
    ),

    ///More → Settings (top-level routes, accessible via push from MoreListPage)
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final isNewUser = extra?['isNewUser'] as bool? ?? false;
        return ProfilePage(isNewUser: isNewUser);
      },
    ),
    GoRoute(
      path: AppRoutes.account,
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: AppRoutes.settingChats,
      builder: (context, state) => const SettingChatsPage(),
    ),
    GoRoute(
      path: AppRoutes.appearance,
      builder: (context, state) => const AppearancePage(),
    ),
    GoRoute(
      path: AppRoutes.notification,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: AppRoutes.privacy,
      builder: (context, state) => const PrivacyPage(),
    ),
    GoRoute(
      path: AppRoutes.dataUsage,
      builder: (context, state) => const DataUsagePage(),
    ),
    GoRoute(path: AppRoutes.help, builder: (context, state) => const HelpPage()),
    GoRoute(
      path: AppRoutes.inviteYourFriends,
      builder: (context, state) => const InviteYourFriendsPage(),
    ),

    /// Dialog — chat conversation page
    GoRoute(
      path: AppRoutes.dialog,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final chatId = extra['chatId'] as String? ?? '';
        final chatName = extra['chatName'] as String? ?? '';
        final chatAvatarUrl = extra['chatAvatarUrl'] as String?;
        final isOnline = extra['isOnline'] as bool? ?? false;
        final currentUserId = (extra['currentUserId'] as String?)?.isNotEmpty == true
            ? extra['currentUserId'] as String
            : (sl<AuthStorage>().getUserId() ?? '');
        return BlocProvider(
          create: (_) => sl<DialogBloc>()
            ..add(LoadMessagesRequested(chatId: chatId)),
          child: DialogPage(
            chatId: chatId,
            chatName: chatName,
            chatAvatarUrl: chatAvatarUrl,
            isOnline: isOnline,
            currentUserId: currentUserId,
          ),
        );
      },
    ),
  ],
);
