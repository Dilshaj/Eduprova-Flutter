import 'package:flutter/material.dart';

import '../network/api_client.dart';

Future<void> showDevServerConfigDialog(BuildContext context) async {
  final controller = TextEditingController(
    text: ApiClient.baseUrlOverride ?? '',
  );
  final messenger = ScaffoldMessenger.of(context);

  await showDialog<void>(
    context: context,
    builder: (context) {
      String? errorText;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Dev API Base URL'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current: ${ApiClient.baseUrl}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: '192.168.1.4',
                    labelText: 'Override IP',
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await ApiClient.clearBaseUrlOverride();
                  if (context.mounted) Navigator.of(context).pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('API URL reset to ${ApiClient.baseUrl}'),
                    ),
                  );
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final value = controller.text.trim();
                  if (value.isEmpty) {
                    setState(() => errorText = 'Please enter a URL');
                    return;
                  }
                  // check it it is ip address or not
                  final ipRegex = RegExp(
                    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
                  );
                  if (!ipRegex.hasMatch(value)) {
                    setState(
                      () => errorText = 'Please enter a valid IP address',
                    );
                    return;
                  }
                  await ApiClient.setBaseUrlOverride(value);
                  if (context.mounted) Navigator.of(context).pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('API URL updated to ${ApiClient.baseUrl}'),
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
