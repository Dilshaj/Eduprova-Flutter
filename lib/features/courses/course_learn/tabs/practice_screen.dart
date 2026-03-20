import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eduprova/features/practice/providers/practice_provider.dart';

// --- Types ---
class LanguageConfig {
  final String id;
  final String name;
  final String pistonName;
  final int judge0Id;
  final String filename;
  final IconData icon;
  final Color color;
  final String startCode;

  LanguageConfig({
    required this.id,
    required this.name,
    required this.pistonName,
    required this.judge0Id,
    required this.filename,
    required this.icon,
    required this.color,
    required this.startCode,
  });
}

// Configuration for Language is managed in individual LanguageConfig

// --- Mock Data ---
final List<LanguageConfig> _languages = [
  LanguageConfig(
    id: 'javascript',
    name: 'JavaScript',
    pistonName: 'javascript',
    judge0Id: 63,
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
    judge0Id: 74,
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
    judge0Id: 71,
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
    judge0Id: 62,
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
    judge0Id: 50,
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
    judge0Id: 54,
    filename: 'main.cpp',
    icon: Icons.code,
    color: const Color(0xFF00599C),
    startCode:
        '#include <iostream>\nusing namespace std;\n\nint main() {\n    cout << "Hello, C++!" << endl;\n    return 0;\n}',
  ),
];

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  late LanguageConfig _selectedLang;
  late TextEditingController _codeController;
  // Execution State is now managed by practiceProvider
  // FullScreen state removed as it is handled by the Navigator route

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
    final List<MapEntry<int, String>> matchesWithIndex = [];

    final printPatterns = [
      RegExp(r'''print\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''console\.log\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''System\.out\.println\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''printf\s*\(\s*["'](.+?)["']\s*\)'''),
      RegExp(r'''cout\s*<<\s*["'](.+?)["']\s*'''),
    ];

    for (final pattern in printPatterns) {
      final matches = pattern.allMatches(codeStr);
      for (final match in matches) {
        if (match.group(1) != null) {
          matchesWithIndex.add(MapEntry(match.start, match.group(1)!));
        }
      }
    }

    // Sort by appearance in code
    matchesWithIndex.sort((a, b) => a.key.compareTo(b.key));

    final simulatedOutputs = matchesWithIndex.map((m) => m.value).toList();

    if (simulatedOutputs.isEmpty) {
      simulatedOutputs.add(
        "Execution Successful (Mock).\nBackend unavailable.",
      );
    }

    return {'stdout': "${simulatedOutputs.join('\n')}\n"};
  }

  Future<void> _handleRunCode() async {
    ref.read(practiceProvider.notifier).clearOutput();

    final validationError = _validateCodeClientSide(
      _selectedLang,
      _codeController.text,
    );
    if (validationError != null) {
      ref.read(practiceProvider.notifier).setOutput({
        'message': '❌ $validationError',
      });
      return;
    }

    final mockResult = await _executeMock(_selectedLang, _codeController.text);

    await ref
        .read(practiceProvider.notifier)
        .runCode(
          pistonName: _selectedLang.pistonName,
          judge0Id: _selectedLang.judge0Id,
          filename: _selectedLang.filename,
          code: _codeController.text,
          mockResult: mockResult,
        );
  }

  void _showLanguageSelector(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: themeExt.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
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
                          color: isSelected
                              ? colorScheme.onSurface
                              : themeExt.secondaryText,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: colorScheme.onSurface,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLang = lang;
                          _codeController.text = lang.startCode;
                          ref.read(practiceProvider.notifier).clearOutput();
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

  Widget _buildEditor(
    BuildContext buildContext,
    bool isFull,
    WidgetRef buildRef,
  ) {
    final themeExt = Theme.of(buildContext).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(buildContext).colorScheme;
    final practiceState = buildRef.watch(practiceProvider);
    final isRunning = practiceState.isRunning;
    final output = practiceState.output;

    return Container(
      decoration: BoxDecoration(
        color: isFull ? const Color(0xFF111827) : themeExt.cardColor,
        borderRadius: isFull ? BorderRadius.zero : BorderRadius.circular(16),
        border: isFull ? null : Border.all(color: themeExt.borderColor),
      ),
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              isFull ? MediaQuery.of(buildContext).padding.top + 8 : 8,
              16,
              8,
            ),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              border: Border(bottom: BorderSide(color: themeExt.borderColor)),
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
                      color: themeExt.skeletonBase,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: themeExt.borderColor),
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: themeExt.secondaryText,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (isFull)
                      InkWell(
                        onTap: isRunning ? null : _handleRunCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isRunning
                                ? const Color(0xFF1E40AF)
                                : const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              isRunning
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
                              if (!isRunning) ...[
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
                      onTap: () async {
                        if (isFull) {
                          Navigator.pop(context);
                        } else {
                          // Push the actual full screen dialog route instead of using a stack inside the View
                          await Navigator.push(
                            buildContext,
                            MaterialPageRoute(
                              builder: (ctx) => Scaffold(
                                backgroundColor:
                                    themeExt.scaffoldBackgroundColor,
                                body: SafeArea(
                                  child: PopScope(
                                    canPop: true,
                                    onPopInvokedWithResult: (didPop, result) {
                                      // Trigger a rebuild when coming back so state syncs
                                      if (didPop) setState(() {});
                                    },
                                    child: Consumer(
                                      builder: (consumerCtx, consumerRef, _) {
                                        return _buildEditor(
                                          consumerCtx,
                                          true,
                                          consumerRef,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                          // Ensure we rebuild to show any output/code changes on return
                          setState(() {});
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                          size: 20,
                          color: isFull ? Colors.white : colorScheme.onSurface,
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
            flex: 7,
            child: Container(
              color: themeExt.cardColor,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    height: 1.5,
                    color: colorScheme.onSurface,
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
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: themeExt.skeletonBase,
                border: Border(top: BorderSide(color: themeExt.borderColor)),
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
                        if (output != null)
                          InkWell(
                            onTap: () => ref
                                .read(practiceProvider.notifier)
                                .clearOutput(),
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
                      child: isRunning
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
                          : output != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (output['message'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      output['message'],
                                      style: const TextStyle(
                                        color: Color(0xFFF87171),
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (output['stderr'] != null &&
                                    output['stderr'].isNotEmpty)
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
                                          output['stderr'],
                                          style: const TextStyle(
                                            color: Color(0xFFFECACA),
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (output['stdout'] != null &&
                                    output['stdout'].isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        output['stdout'],
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
                          : Text(
                              'Ready to execute.',
                              style: TextStyle(
                                color: themeExt.secondaryText,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isFull)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeExt.cardColor,
                border: Border(top: BorderSide(color: themeExt.borderColor)),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: InkWell(
                onTap: isRunning ? null : _handleRunCode,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isRunning
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (!isRunning)
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isRunning
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
    // Hot reload safety: reassign to the newly constructed object reference
    // so it picks up the newly added judge0Id field.
    _selectedLang = _languages.firstWhere(
      (lang) => lang.id == _selectedLang.id,
      orElse: () => _languages[0],
    );

    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      resizeToAvoidBottomInset:
          false, // Prevent terminal crushing on keyboard open
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24 + 48, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildEditor(context, false, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
