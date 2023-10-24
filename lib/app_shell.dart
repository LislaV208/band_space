import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/utils/context_extensions.dart';

class NavItem {
  final Icon icon;
  final String label;

  const NavItem({required this.icon, required this.label});
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late var _selectedIndex = _calculateSelectedIndex();

  final destinations = {
    const NavItem(
      icon: Icon(Icons.folder_copy),
      label: 'Projekty',
    ),
    const NavItem(
      icon: Icon(Icons.account_circle_outlined),
      label: 'Profil',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final user = sl.get<AuthService>().user;

    final useBottomNavigation = context.useBottomNavigation;

    return Scaffold(
      bottomNavigationBar: useBottomNavigation
          ? NavigationBar(
              destinations: destinations
                  .map(
                    (item) => NavigationDestination(
                      icon: item.icon,
                      label: item.label,
                    ),
                  )
                  .toList(),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
            )
          : null,
      body: Row(
        children: [
          if (!useBottomNavigation)
            NavigationRail(
              leading: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      'BandSpace',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8.0),
                    SelectableText(
                      user?.id ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                ),
              ),
              destinations: destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.icon,
                      label: Text(item.label),
                    ),
                  )
                  .toList(),
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _onItemTapped(index, context),
              extended: true,
              backgroundColor: Colors.blueGrey[900]?.withOpacity(0.5),
            ),
          Expanded(
            child: Scaffold(
              body: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex() {
    final String location = GoRouterState.of(context).location;

    if (location.startsWith('/projects')) {
      return 0;
    } else if (location.startsWith('/profile')) {
      return 1;
    }

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        GoRouter.of(context).go('/projects');
        break;
      case 1:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
