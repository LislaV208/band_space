import 'package:band_space/app_shell.dart';
import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/screens/register_screen.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/auth/screens/login_screen.dart';
import 'package:band_space/project/screens/confirm_invitation_screen.dart';
import 'package:band_space/project/screens/project_details_screen.dart';
import 'package:band_space/project/screens/projects_screen.dart';
import 'package:band_space/song/screens/song_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/projects',
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
          redirect: (context, state) async {
            final isLoggedIn = sl.get<AuthService>().isUserAuthenticated;

            if (!isLoggedIn) return '/login';

            return null;
          },
          routes: [
            GoRoute(
              path: ':project_id',
              name: 'project_details',
              builder: (context, state) {
                return ProjectDetailsScreen(
                  projectId: state.pathParameters['project_id']!,
                );
              },
              routes: [
                GoRoute(
                  path: ':song_id',
                  name: 'song',
                  builder: (context, state) {
                    return SongScreen(
                      projectId: state.pathParameters['project_id']!,
                      songId: state.pathParameters['song_id']!,
                    );
                  },
                ),
              ],
            ),
          ],
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

        return ConfirmInvitationScreen(
          projectId: projectId,
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
