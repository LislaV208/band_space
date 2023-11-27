import 'package:flutter/material.dart';

import 'package:band_space/user/model/personal_data.dart';
import 'package:band_space/user/user_provider.dart';
import 'package:band_space/widgets/app_button_primary.dart';

class FillPersonalDataWiget extends StatefulWidget {
  const FillPersonalDataWiget({
    super.key,
    required this.userProvider,
  });

  final UserProvider userProvider;

  @override
  State<FillPersonalDataWiget> createState() => _FillPersonalDataWigetState();
}

class _FillPersonalDataWigetState extends State<FillPersonalDataWiget> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
            maxHeight: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Uzupełnij swoje dane',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Expanded(
                  child: Align(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Te informacje będą widoczne tylko dla członków Twoich projektów',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32.0),
                          TextFormField(
                            controller: _nameController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: 'Imię',
                            ),
                            validator: _validator,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              hintText: 'Nazwisko',
                            ),
                            validator: _validator,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Przypomnij później'),
                    ),
                    AppButtonPrimary(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          final name = _nameController.text;
                          final surname = _surnameController.text;
                          final personalData = PersonalData(name: name, surname: surname);

                          await widget.userProvider.updatePersonalData(personalData);

                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      text: 'Zapisz',
                      expanded: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validator(String? input) {
    if (input == null || input.isEmpty) {
      return 'Uzupełnij to pole';
    }

    return null;
  }
}
