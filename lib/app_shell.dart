import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/core/base_bloc_state.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = sl.get<AuthService>().user;

    return Scaffold(
      body: Row(
        children: [
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
                  if (user != null)
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FutureBuilder(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();

                        return Text(
                          'v${snapshot.data!.version}',
                          style: const TextStyle(color: Colors.grey),
                        );
                      }),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Pulpit'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.folder_copy),
                label: Text('Projekty'),
              ),
            ],
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(index, context),
            extended: true,
            backgroundColor: Colors.blueGrey[900],
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocConsumer<AuthCubit, BaseBlocState>(
                      listener: (context, state) {
                        if (state is CompletedState) {
                          context.goNamed('login');
                        }
                      },
                      builder: (context, state) {
                        return IconButton(
                          onPressed: () async {
                            sl.get<AuthService>().signOut();

                            if (context.mounted) {
                              context.goNamed('login');
                            }
                          },
                          icon: const Icon(Icons.logout),
                        );
                      },
                    ),
                  ),
                ],
              ),
              body: child,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).location;
    if (location == '/') {
      return 0;
    }
    if (location.startsWith('/projects')) {
      return 1;
    }

    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/projects');
        break;
    }
  }
}
