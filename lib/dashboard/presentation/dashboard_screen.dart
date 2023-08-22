import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Projekty',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              // onTap: () => context.goNamed('projects'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              tileColor: Theme.of(context).colorScheme.onSecondary,
              contentPadding: const EdgeInsets.all(16.0),
            ),
          ],
        ),
      ),
    );
  }
}
