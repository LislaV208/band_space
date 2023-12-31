import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:band_space/app_shell/app_shell.dart';
import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/screens/login_screen.dart';
import 'package:band_space/auth/screens/register_screen.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/profile/profile_screen.dart';
import 'package:band_space/project/cubit/project_cubit.dart';
import 'package:band_space/project/repository/project_repository.dart';
import 'package:band_space/project/screens/confirm_invitation_screen.dart';
import 'package:band_space/project/screens/project_details_screen.dart';
import 'package:band_space/project/screens/projects_screen.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/screens/song_screen.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/projects',
  redirect: (context, state) async {
    final isLoggedIn = sl.get<AuthService>().isUserAuthenticated;

    if (!isLoggedIn) {
      final allowedRoutes = ['/login', '/register', '/invite'];

      if (allowedRoutes.contains(state.location)) {
        return null;
      }

      return '/login';
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/projects',
          name: 'projects',
          builder: (context, state) => const ProjectsScreen(),
          routes: [
            GoRoute(
              path: ':project_id',
              name: 'project_details',
              builder: (context, state) {
                final projectId = state.pathParameters['project_id']!;

                return MultiProvider(
                  providers: [
                    Provider(
                      create: (context) => sl<ProjectRepository>(param1: projectId),
                    ),
                    Provider(
                      create: (context) => ProjectCubit(
                        projectRepository: sl<ProjectRepository>(param1: projectId),
                      ),
                      dispose: (context, cubit) => cubit.dispose(),
                    ),
                  ],
                  child: const ProjectDetailsScreen(),
                );
              },
              routes: [
                GoRoute(
                  path: ':song_id',
                  name: 'song',
                  builder: (context, state) {
                    final songId = state.pathParameters['song_id']!;

                    return MultiProvider(
                      providers: [
                        Provider(
                          create: (context) => sl<SongRepository>(param1: songId),
                        ),
                      ],
                      child: const SongScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) {
        final queryParams = state.queryParameters;
        final redirect = queryParams['redirect'];
        String? arg;
        if (redirect == 'invite') {
          arg = queryParams['project'];
        }

        return LoginScreen(redirect: redirect, redirectArg: arg);
      },
      redirect: (context, state) {
        final isLoggedIn = sl.get<AuthService>().isUserAuthenticated;
        if (isLoggedIn) return '/projects';

        return null;
      },
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) {
        final queryParams = state.queryParameters;
        final redirect = queryParams['redirect'];
        String? arg;
        if (redirect == 'invite') {
          arg = queryParams['project'];
        }
        return RegisterScreen(redirect: redirect, redirectArg: arg);
      },
    ),
    GoRoute(
      path: '/invite',
      name: 'invite',
      builder: (context, state) {
        final projectId = state.queryParameters['project'] ?? '';

        return Provider(
          create: (context) => sl<ProjectRepository>(param1: projectId),
          child: const ConfirmInvitationScreen(),
        );
      },
      redirect: (context, state) {
        final projectId = state.queryParameters['project'] ?? '';

        final isLoggedIn = sl.get<AuthService>().isUserAuthenticated;

        if (!isLoggedIn) {
          return '/login?redirect=invite&project=$projectId';
        }

        return null;
      },
    ),
  ],
);
