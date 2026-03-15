import 'dart:convert';
import 'package:http/http.dart' as http;

class PracticeRepository {
  static const String executionApiUrl =
      "https://ce.judge0.com/submissions?base64_encoded=false&wait=true";

  Future<Map<String, dynamic>> executeCode({
    required String pistonName,
    required String filename,
    required String code,
    int? judge0Id,
  }) async {
    try {
      final payload = {
        'source_code': code,
        'language_id': judge0Id ?? 63,
        'stdin': "",
      };

      final response = await http
          .post(
            Uri.parse(executionApiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'stdout': data['stdout'],
          'stderr': data['stderr'] ?? data['compile_output'],
          'message':
              data['message'] ??
              (data['status']?['description'] == 'Accepted'
                  ? null
                  : data['status']?['description']),
        };
      }
      return {'message': '❌ Execution failed (Status: ${response.statusCode})'};
    } catch (e) {
      return {'message': '❌ Failed to connect to execution server. Error: $e'};
    }
  }
}
