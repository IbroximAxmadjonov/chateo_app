import 'package:get_it/get_it.dart';

import 'core/init_core_injection.dart';
import 'features/auth/init_auth_injection.dart';
import 'features/chats/init_chats_injection.dart';
import 'features/contacts/init_contacts_injection.dart';
import 'features/dialog/init_dialog_injection.dart';
import 'features/settings/profile/init_profile_injection.dart';

/// sl = Service Locator
final sl = GetIt.instance;

Future<void> initializeInjection() async {
  /// Features - Bloc, Use Cases, Repository, Data sources

  /// 1 Auth Feature
  initAuthInjection(sl);

  /// 2 Contacts Feature
  initContactsInjection(sl);

  /// 3 Chats Feature
  initChatsInjection(sl);

  /// 4 Dialog Feature
  initDialogInjection(sl);

  /// 5 Profile Feature
  initProfileInjection(sl);

  /// Core
  await initCoreInjection(sl);
}
