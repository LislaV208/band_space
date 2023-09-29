import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/core/base_bloc_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.redirect, this.redirectArg});

  final String? redirect;
  final String? redirectArg;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!Platform.isAndroid && !Platform.isIOS)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
                child: Text(
                  'BandSpace',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            Card(
              margin: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 440),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rejestracja',
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
                                  : const Text('Utwórz konto'),
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
                            'login',
                            queryParameters: queryParams,
                          );
                        },
                        child: const Text('Zaloguj się'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    context.read<AuthCubit>().signUp(_emailController.text, _passwordController.text);
  }
}
