import 'package:band_space/app_shell.dart';
import 'package:band_space/auth/auth_service.dart';
import 'package:band_space/auth/screens/register_screen.dart';
import 'package:band_space/core/service_locator.dart';
import 'package:band_space/auth/screens/login_screen.dart';
import 'package:band_space/dashboard/presentation/dashboard_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
          redirect: (context, state) async {
            final isLoggedIn = sl.get<AuthService>().isUserAuthenticated;

            if (!isLoggedIn) return '/login';

            return null;
          },
          // routes: [
          //   GoRoute(
          //     path: 'projects',
          //     name: 'projects',
          //     builder: (context, state) => const ProjectsScreen(),
          //     routes: [
          //       GoRoute(
          //         path: 'new',
          //         name: 'new-project',
          //         builder: (context, state) => const NewProjectScreen(),
          //       ),
          //       GoRoute(
          //         path: ':name',
          //         name: 'songs',
          //         builder: (context, state) => SongsScreen(
          //           projectPathName: state.pathParameters['name']!,
          //         ),
          //         routes: [
          //           GoRoute(
          //             path: 'new-song',
          //             name: 'new-song',
          //             builder: (context, state) => NewSongScreen(
          //               projectName: state.pathParameters['name']!,
          //             ),
          //           ),
          //           GoRoute(
          //             path: ':songName',
          //             name: 'song',
          //             builder: (context, state) => SongScreen(
          //               projectPathName: state.pathParameters['name']!,
          //               songPathName: state.pathParameters['songName']!,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
      // routes: [
      //   GoRoute(
      //     path: 'verification-code',
      //     builder: (context, state) {
      //       final email = state.extra as String;
      //       return VerificationCodeScreen(email: email);
      //     },
      //     redirect: (context, state) {
      //       if (state.extra == null) return '/register';

      //       return null;
      //     },
      //   ),
      // ],
    ),
  ],
);
