import 'package:flutter/material.dart';

import '../network/api_client.dart';

Future<void> showDevServerConfigDialog(BuildContext context) async {
  final controller = TextEditingController(text: ApiClient.baseUrlOverride ?? '');
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
                    hintText: 'http://192.168.1.4:4000',
                    labelText: 'Override URL',
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
                    SnackBar(content: Text('API URL reset to ${ApiClient.baseUrl}')),
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
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
                    setState(() => errorText = 'Enter valid URL, e.g. http://192.168.1.4:4000');
                    return;
                  }
                  await ApiClient.setBaseUrlOverride(value);
                  if (context.mounted) Navigator.of(context).pop();
                  messenger.showSnackBar(
                    SnackBar(content: Text('API URL updated to ${ApiClient.baseUrl}')),
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
