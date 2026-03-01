import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- Types ---
class LanguageConfig {
  final String id;
  final String name;
  final String pistonName;
  final String filename;
  final IconData icon;
  final Color color;
  final String startCode;

  LanguageConfig({
    required this.id,
    required this.name,
    required this.pistonName,
    required this.filename,
    required this.icon,
    required this.color,
    required this.startCode,
  });
}

// --- Configuration ---
const String executionApiUrl = "http://localhost:2000/api/v2/execute";

// --- Mock Data ---
final List<LanguageConfig> _languages = [
  LanguageConfig(
    id: 'javascript',
    name: 'JavaScript',
    pistonName: 'javascript',
    filename: 'index.js',
    icon: Icons.javascript,
    color: const Color(0xFFF7DF1E),
    startCode:
        'console.log("Hello, World!");\n\nfunction greet(name) {\n    return "Hello, " + name + "!";\n}\n\nconsole.log(greet("Developer"));',
  ),
  LanguageConfig(
    id: 'typescript',
    name: 'TypeScript',
    pistonName: 'typescript',
    filename: 'index.ts',
    icon: Icons.text_snippet,
    color: const Color(0xFF3178C6),
    startCode:
        'const message: string = "Hello, TypeScript!";\nconsole.log(message);',
  ),
  LanguageConfig(
    id: 'python',
    name: 'Python 3',
    pistonName: 'python',
    filename: 'main.py',
    icon: Icons.code,
    color: const Color(0xFF3776AB),
    startCode:
        'print("Hello, World!")\n\ndef greet(name):\n    return f"Hello, {name}!"\n\nprint(greet("Developer"))',
  ),
  LanguageConfig(
    id: 'java',
    name: 'Java',
    pistonName: 'java',
    filename: 'Main.java',
    icon: Icons.local_cafe,
    color: const Color(0xFFE76F00),
    startCode:
        'public class Main {\n    public static void main(String[] args) {\n        System.out.println("Hello, Java!");\n    }\n}',
  ),
  LanguageConfig(
    id: 'c',
    name: 'C (GCC)',
    pistonName: 'c',
    filename: 'main.c',
    icon: Icons.code,
    color: const Color(0xFFA8B9CC),
    startCode:
        '#include <stdio.h>\n\nint main() {\n    printf("Hello, C Language!\\n");\n    return 0;\n}',
  ),
  LanguageConfig(
    id: 'cpp',
    name: 'C++ (G++)',
    pistonName: 'c++',
    filename: 'main.cpp',
    icon: Icons.code,
    color: const Color(0xFF00599C),
    startCode:
        '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Hello, C++!" << endl;\n    return 0;\n}',
  ),
];

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late LanguageConfig _selectedLang;
  late TextEditingController _codeController;
  Map<String, dynamic>? _output;
  bool _isRunning = false;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _selectedLang = _languages[0];
    _codeController = TextEditingController(text: _selectedLang.startCode);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String? _validateCodeClientSide(LanguageConfig lang, String codeStr) {
    if (codeStr.trim().isEmpty) return "Code is empty.";
    final c = codeStr.toLowerCase();
    if ([
      'java',
      'c',
      'cpp',
      'csharp',
      'javascript',
      'typescript',
    ].contains(lang.id)) {
      if (c.contains('def ') &&
          c.contains(':') &&
          !c.contains('function') &&
          !c.contains('class')) {
        return "Syntax Error: Python function definition detected.";
      }
    }
    if (lang.id == 'python') {
      if (c.contains('public static void main')) {
        return "Syntax Error: Java main method detected.";
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _executeMock(
    LanguageConfig lang,
    String codeStr,
  ) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    String simulatedOutput =
        "Execution Successful (Mock).\nBackend unavailable.";

    final printPatterns = [
      RegExp(r'''print\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''console\.log\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''System\.out\.println\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''printf\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''cout\s*<<\s*["'](.+?)["']\s*'''),
    ];

    for (final pattern in printPatterns) {
      final match = pattern.firstMatch(codeStr);
      if (match != null) {
        simulatedOutput = match.group(1) ?? simulatedOutput;
        break;
      }
    }
    return {'stdout': "$simulatedOutput\n"};
  }

  Future<void> _handleRunCode() async {
    setState(() {
      _output = null;
    });

    final validationError = _validateCodeClientSide(
      _selectedLang,
      _codeController.text,
    );
    if (validationError != null) {
      setState(() {
        _output = {'message': '❌ $validationError'};
      });
      return;
    }

    setState(() {
      _isRunning = true;
    });

    try {
      final payload = {
        'language': _selectedLang.pistonName,
        'version': '*',
        'files': [
          {'name': _selectedLang.filename, 'content': _codeController.text},
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
          setState(() {
            _output = {
              'stdout': data['run']['stdout'],
              'stderr': data['run']['stderr'],
              'message': data['run']['code'] != 0
                  ? 'Process exited with code ${data['run']['code']}'
                  : null,
            };
          });
        } else {
          setState(() {
            _output = {'message': '❌ Invalid response.'};
          });
        }
      } else {
        final mockResult = await _executeMock(
          _selectedLang,
          _codeController.text,
        );
        setState(() {
          _output = mockResult;
        });
      }
    } catch (e) {
      final mockResult = await _executeMock(
        _selectedLang,
        _codeController.text,
      );
      setState(() {
        _output = mockResult;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLang.id == lang.id;
                    return ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: lang.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      title: Text(
                        lang.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Colors.black : Colors.black54,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.black,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLang = lang;
                          _codeController.text = lang.startCode;
                          _output = null;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditor(bool isFull) {
    return Container(
      decoration: BoxDecoration(
        color: isFull ? const Color(0xFF111827) : Colors.white,
        borderRadius: isFull ? BorderRadius.zero : BorderRadius.circular(16),
        border: isFull ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              isFull ? MediaQuery.of(context).padding.top + 8 : 8,
              16,
              8,
            ),
            decoration: BoxDecoration(
              color: isFull ? const Color(0xFF111111) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isFull
                      ? const Color(0xFF1F2937)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              borderRadius: isFull
                  ? BorderRadius.zero
                  : const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _showLanguageSelector(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isFull
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isFull
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _selectedLang.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          _selectedLang.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isFull
                                ? Colors.white
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: isFull ? Colors.white70 : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (isFull)
                      InkWell(
                        onTap: _isRunning ? null : _handleRunCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _isRunning
                                ? const Color(0xFF1E40AF)
                                : const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _isRunning
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.play_arrow,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                              if (!_isRunning) ...[
                                const SizedBox(width: 6),
                                const Text(
                                  'RUN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        if (isFull) {
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            _isFullScreen = true;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                          size: 20,
                          color: isFull
                              ? Colors.white
                              : const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Code Input Area
          Expanded(
            flex: isFull ? 6 : 0,
            child: Container(
              height: isFull ? null : 350,
              color: isFull ? const Color(0xFF1E1E1E) : Colors.white,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                    color: isFull ? const Color(0xFFD4D4D4) : Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ),

          // Console Area
          Container(
            height: isFull ? 200 : 150,
            decoration: const BoxDecoration(
              color: Color(0xFF0D1117),
              border: Border(top: BorderSide(color: Color(0xFF1F2937))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0x0DFFFFFF),
                    border: Border(
                      bottom: BorderSide(color: Color(0x1AFFFFFF)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CONSOLE',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (_output != null)
                        InkWell(
                          onTap: () => setState(() => _output = null),
                          child: const Text(
                            'CLEAR',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _isRunning
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2563EB),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Executing container...',
                                style: TextStyle(
                                  color: Color(0xFF60A5FA),
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          )
                        : _output != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_output!['message'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    _output!['message'],
                                    style: const TextStyle(
                                      color: Color(0xFFF87171),
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              if (_output!['stderr'] != null &&
                                  _output!['stderr'].isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'STDERR:',
                                        style: TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _output!['stderr'],
                                        style: const TextStyle(
                                          color: Color(0xFFFECACA),
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_output!['stdout'] != null &&
                                  _output!['stdout'].isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'STDOUT:',
                                      style: TextStyle(
                                        color: Color(0xFF22C55E),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _output!['stdout'],
                                      style: const TextStyle(
                                        color: Color(0xFF86EFAC),
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        : const Text(
                            'Ready to execute.',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          if (!isFull)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: InkWell(
                onTap: _isRunning ? null : _handleRunCode,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _isRunning
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (!_isRunning)
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'RUN CODE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24 + 48, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isFullScreen)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF2563EB),
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'CODE PRACTICE',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildEditor(false),
                ),
              ],
            ),
          ),
        ),

        // Full Screen Editor Overlay
        if (_isFullScreen)
          Positioned.fill(
            child: Container(color: Colors.black, child: _buildEditor(true)),
          ),
      ],
    );
  }
}
