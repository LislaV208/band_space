import 'package:band_space/core/service_locator.dart';
import 'package:band_space/project/repository/user_projects_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _titleController = TextEditingController();

  var _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isAdding,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nowy projekt'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      TextField(
                        autofocus: true,
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nazwa',
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: FilledButton(
                        onPressed: _isAdding
                            ? null
                            : () async {
                                final name = _titleController.text;
                                if (name.isNotEmpty) {
                                  setState(() {
                                    _isAdding = true;
                                  });

                                  await sl<UserProjectsRepository>().addProject(name);

                                  if (!mounted) return;

                                  context.pop();
                                }
                              },
                        child: _isAdding
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                ),
                              )
                            : Text('Utwórz'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
