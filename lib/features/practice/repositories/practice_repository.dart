import 'dart:convert';
import 'package:http/http.dart' as http;

class PracticeRepository {
  // Configured correctly based on practice_screen.dart
  static const String executionApiUrl = "http://localhost:2000/api/v2/execute";

  Future<Map<String, dynamic>> executeCode({
    required String pistonName,
    required String filename,
    required String code,
  }) async {
    try {
      final payload = {
        'language': pistonName,
        'version': '*',
        'files': [
          {'name': filename, 'content': code},
        ],
      };

      final response = await http
          .post(
            Uri.parse(executionApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['run'] != null) {
          return {
            'stdout': data['run']['stdout'],
            'stderr': data['run']['stderr'],
            'message': data['run']['code'] != 0
                ? 'Process exited with code ${data['run']['code']}'
                : null,
          };
        }
      }
      return {'message': '❌ Execution failed (Status: ${response.statusCode})'};
    } catch (e) {
      return {'message': '❌ Failed to connect to execution server.'};
    }
  }
}
