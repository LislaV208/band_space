import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:band_space/app_config.dart';
import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/core/logger.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:band_space/user/repository/user_repository.dart';
import 'package:band_space/user/user_provider.dart';
import 'package:band_space/user/widgets/fill_personal_data_widget.dart';
import 'package:band_space/utils/context_extensions.dart';

part 'app_shell_view.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late Future<UserModel> _userFuture;
  var showError = false;

  @override
  void initState() {
    super.initState();
    final userId = sl<AuthService>().userId;
    if (userId == null) {
      showError = true;
    }

    _userFuture = sl<UserRepository>().getUser(userId ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoadingScreen();
        }

        final user = snapshot.data;
        if (user == null) {
          return _buildErrorScreen();
        }

        return ChangeNotifierProvider(
          create: (context) => UserProvider(
            userRepository: sl<UserRepository>(),
            user: user,
          ),
          child: _AppShellView(child: widget.child),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return const Scaffold(
      body: Center(
        child: Text('Wystąpił błąd aplikacji (user == null)'),
      ),
    );
  }
}
