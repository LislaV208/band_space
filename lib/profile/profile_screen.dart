import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/user/user_provider.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/widgets/app_button_secondary.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Align(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      child: Icon(
                        Icons.account_circle_outlined,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<UserProvider>(
                      builder: (context, provider, child) => Text(
                        provider.user.fullName,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppButtonSecondary(
                      onTap: () {
                        context.showErrorSnackbar(message: 'Not implemented');
                      },
                      text: 'Zmień hasło',
                      icon: const Icon(
                        Icons.lock_outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppButtonSecondary(
                      onTap: () {
                        context.showErrorSnackbar(message: 'Not implemented');
                      },
                      text: 'Usuń konto',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              context.useBottomNavigation
                  ? Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              await sl.get<AuthService>().signOut();

                              if (context.mounted) {
                                context.goNamed('login');
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Wyloguj'),
                          ),
                          const SizedBox(height: 24),
                          FutureBuilder(
                              future: PackageInfo.fromPlatform(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox();

                                return Text(
                                  'v${snapshot.data!.version}',
                                  style: const TextStyle(color: Colors.grey),
                                );
                              }),
                        ],
                      ),
                    )
                  : const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
