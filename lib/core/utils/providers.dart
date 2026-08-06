import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

import '../../features/auth/presentation/manager/auth_bloc.dart';
import '../../features/chats/presentation/manager/chats_bloc.dart';
import '../../features/contacts/presentation/manager/contacts_bloc.dart';
import '../../features/settings/profile/presentation/manager/profile_bloc.dart';
import '../../service_locator.dart';
import 'bloc/theme/theme_bloc.dart';

final List<SingleChildWidget> providers = [
  BlocProvider(create: (_) => ThemeBloc()),
  BlocProvider(create: (_) => sl<AuthBloc>()..add(const AuthCheckStatusRequested())),
  BlocProvider(create: (_) => sl<ChatsBloc>()),
  BlocProvider(create: (_) => sl<ContactsBloc>()),
  BlocProvider(create: (_) => sl<ProfileBloc>()),
];
