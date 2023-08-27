import 'package:band_space/auth/cubit/auth_cubit.dart';
import 'package:band_space/core/base_bloc_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'BandSpace',
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
          ),
          Center(
            child: Card(
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
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Hasło',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      BlocConsumer<AuthCubit, BaseBlocState>(
                        listener: (context, state) {
                          if (state is CompletedState) {
                            context.goNamed('projects');
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
                              onPressed: state is LoadingState
                                  ? null
                                  : () async {
                                      context.read<AuthCubit>().signUp(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                    },
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
                          context.goNamed('login');
                        },
                        child: const Text('Zaloguj się'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
