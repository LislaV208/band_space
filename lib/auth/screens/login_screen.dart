import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/core/base_bloc_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.redirect, this.redirectArg});

  final String? redirect;
  final String? redirectArg;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(
    text: kDebugMode ? 'lislav.hms@gmail.com' : null,
  );
  final _passwordController = TextEditingController(
    text: kDebugMode ? '@rbuz0Hol' : null,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 440),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Logowanie',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    autofocus: true,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Hasło',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onSubmit(),
                  ),
                  const SizedBox(height: 32.0),
                  BlocConsumer<AuthCubit, BaseBlocState>(
                    listener: (context, state) {
                      if (state is CompletedState) {
                        if (widget.redirect != null) {
                          final queryParams = <String, dynamic>{};
                          if (widget.redirect == 'invite') {
                            queryParams.addAll({
                              'project': widget.redirectArg ?? '',
                            });
                          }

                          context.goNamed(
                            widget.redirect!,
                            queryParameters: queryParams,
                          );
                        } else {
                          context.goNamed('projects');
                        }
                      } else if (state is FailureState) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${state.error}'),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: FilledButton(
                          onPressed: state is LoadingState ? null : _onSubmit,
                          child: state is LoadingState
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                              : const Text('Zaloguj'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: () {
                      final queryParams = <String, dynamic>{};
                      if (widget.redirect != null) {
                        if (widget.redirect == 'invite') {
                          queryParams.addAll({
                            'redirect': 'invite',
                            'project': widget.redirectArg ?? '',
                          });
                        }
                      }
                      context.goNamed(
                        'register',
                        queryParameters: queryParams,
                      );
                    },
                    child: const Text('Zarejestruj się'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    context.read<AuthCubit>().logIn(_emailController.text, _passwordController.text);
  }
}
