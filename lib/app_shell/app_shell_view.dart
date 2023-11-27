part of 'app_shell.dart';

class _NavItem {
  final Icon icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

class _AppShellView extends StatefulWidget {
  const _AppShellView({required this.child});

  final Widget child;

  @override
  State<_AppShellView> createState() => __AppShellViewState();
}

class __AppShellViewState extends State<_AppShellView> {
  late var _selectedIndex = _calculateSelectedIndex();

  final destinations = {
    const _NavItem(
      icon: Icon(Icons.folder_copy),
      label: 'Projekty',
    ),
    const _NavItem(
      icon: Icon(Icons.account_circle_outlined),
      label: 'Profil',
    ),
  };

  @override
  void initState() {
    super.initState();

    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    Logger.setUser(user.id, user.email);
    if (user.personal_data == null) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => FillPersonalDataWiget(
            userProvider: userProvider,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: Builder(builder: (context) {
                  final user = context.watch<UserProvider>().user;

                  return Column(
                    children: [
                      Text(
                        'BandSpace',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      // const SizedBox(height: 8.0),
                      // SelectableText(
                      //   user.id,
                      //   style: Theme.of(context).textTheme.bodySmall,
                      // ),
                    ],
                  );
                }),
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

                            final env = config.env == 'prod' ? '' : config.env;

                            return Text(
                              'v${snapshot.data!.version} $env',
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
