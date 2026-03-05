import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'package:eduprova/theme.dart';
import 'package:path_provider/path_provider.dart';

// HTML Template Generation
String getEditorHtml(String initialContent, bool isDark) {
  return '''
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
    <style>
        * {
            box-sizing: border-box;
            -webkit-tap-highlight-color: transparent;
        }
        body { 
            margin: 0; 
            padding: 20px; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; 
            background-color: ${isDark ? '#000000' : '#ffffff'}; 
            color: ${isDark ? '#e5e7eb' : '#1f2937'}; 
            min-height: 100vh;
        }
        #editor { 
            min-height: 300px; 
            outline: none; 
            font-size: 14px; 
            line-height: 1.6;
            padding-bottom: 50vh; /* Space for scrolling above keyboard */
        }
        #editor:empty:before {
            content: attr(placeholder);
            color: ${isDark ? '#6b7280' : '#9ca3af'};
            display: block;
        }
        
        /* Heading Styles */
        h1 { font-size: 28px; font-weight: bold; margin: 12px 0; line-height: 1.3; }
        h2 { font-size: 22px; font-weight: 600; margin: 12px 0; line-height: 1.35; color: ${isDark ? '#d1d5db' : '#374151'}; }
        h3 { font-size: 18px; font-weight: 600; margin: 10px 0; line-height: 1.4; }
        h4 { font-size: 16px; font-weight: 600; margin: 10px 0; line-height: 1.45; }
        h5 { font-size: 14px; font-weight: bold; margin: 8px 0; line-height: 1.5; text-transform: uppercase; letter-spacing: 0.5px; }
        h6 { font-size: 13px; font-weight: bold; margin: 8px 0; line-height: 1.5; color: ${isDark ? '#9ca3af' : '#6b7280'}; }
        p, div { font-size: 14px; margin: 8px 0; line-height: 1.6; }
        
        b, strong { font-weight: bold; }
        i, em { font-style: italic; }
        
        ul, ol { padding-left: 24px; margin: 8px 0; }
        li { margin-bottom: 4px; }

        blockquote { 
            border-left: 3px solid #0066FF; 
            margin: 12px 0; 
            padding-left: 16px; 
            color: ${isDark ? '#9ca3af' : '#6b7280'};
            font-style: italic;
        }
    </style>
</head>
<body>
    <div id="editor" contenteditable="true" placeholder="Start typing your module notes...">$initialContent</div>
    <script>
        const editor = document.getElementById('editor');
        
        // Notify ready
        if (window.FlutterWebView) {
            window.FlutterWebView.postMessage(JSON.stringify({ type: 'ready' }));
        }

        const sendSelectionState = () => {
             const selection = window.getSelection();
             if (selection.rangeCount > 0) {
                 const range = selection.getRangeAt(0);
                 let parent = range.commonAncestorContainer;
                 if (parent.nodeType === 3) {
                     parent = parent.parentNode;
                 }
                 
                 let blockType = 'p';
                 let current = parent;
                 
                 // Traverse up to find block element
                 while(current && current.id !== 'editor') {
                     const tag = current.tagName ? current.tagName.toLowerCase() : '';
                     if (['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'p', 'div', 'li', 'blockquote'].includes(tag)) {
                         blockType = tag;
                         break;
                     }
                     current = current.parentNode;
                 }

                 const isBold = document.queryCommandState('bold');
                 const isItalic = document.queryCommandState('italic');
                 const isUnordered = document.queryCommandState('insertUnorderedList');
                 const isOrdered = document.queryCommandState('insertOrderedList');
                 
                 if (window.FlutterWebView) {
                     window.FlutterWebView.postMessage(JSON.stringify({
                         type: 'selection',
                         data: { blockType, isBold, isItalic, isUnordered, isOrdered }
                     }));
                 }
             }
        };

        // Input & Selection Listeners
        editor.addEventListener('input', function() {
            if (window.FlutterWebView) {
                window.FlutterWebView.postMessage(JSON.stringify({ type: 'content', data: this.innerHTML }));
            }
            sendSelectionState();
        });

        editor.addEventListener('keyup', sendSelectionState);
        editor.addEventListener('mouseup', sendSelectionState);
        editor.addEventListener('click', sendSelectionState);
        document.addEventListener('selectionchange', sendSelectionState);

        function handleCommand(command, args) {
            editor.focus();
            if (command === 'format') {
                document.execCommand(args, false, null);
            } else if (command === 'style') {
                document.execCommand('formatBlock', false, args);
            } else if (command === 'list') {
                if (args === 'ul') document.execCommand('insertUnorderedList', false, null);
                if (args === 'ol') document.execCommand('insertOrderedList', false, null);
            } else if (command === 'setHtml') {
                if (editor.innerHTML !== args) {
                    editor.innerHTML = args;
                }
            }
            sendSelectionState();
        }
        
        // Prevent zoom
        document.addEventListener('gesturestart', function(e) { e.preventDefault(); });
    </script>
</body>
</html>
''';
}

class EditorState {
  final String blockType;
  final bool isBold;
  final bool isItalic;
  final bool isUnordered;
  final bool isOrdered;

  EditorState({
    required this.blockType,
    required this.isBold,
    required this.isItalic,
    required this.isUnordered,
    required this.isOrdered,
  });

  factory EditorState.initial() => EditorState(
    blockType: 'p',
    isBold: false,
    isItalic: false,
    isUnordered: false,
    isOrdered: false,
  );
}

class HeadingOption {
  final String label;
  final String tag;
  final double fontSize;
  final String style;
  final String desc;

  const HeadingOption({
    required this.label,
    required this.tag,
    required this.fontSize,
    required this.style,
    required this.desc,
  });
}

const List<HeadingOption> headingOptions = [
  HeadingOption(
    label: 'Title',
    tag: 'H1',
    fontSize: 28,
    style: 'bold',
    desc: 'Heading 1',
  ),
  HeadingOption(
    label: 'Subtitle',
    tag: 'H2',
    fontSize: 22,
    style: 'semibold',
    desc: 'Heading 2',
  ),
  HeadingOption(
    label: 'Heading',
    tag: 'H3',
    fontSize: 18,
    style: 'semibold',
    desc: 'Heading 3',
  ),
  HeadingOption(
    label: 'Subheading',
    tag: 'H4',
    fontSize: 16,
    style: 'semibold',
    desc: 'Heading 4',
  ),
  HeadingOption(
    label: 'Section',
    tag: 'H5',
    fontSize: 14,
    style: 'bold',
    desc: 'Heading 5',
  ),
  HeadingOption(
    label: 'Subsection',
    tag: 'H6',
    fontSize: 13,
    style: 'bold',
    desc: 'Heading 6',
  ),
  HeadingOption(
    label: 'Body',
    tag: 'P',
    fontSize: 14,
    style: 'normal',
    desc: 'Paragraph',
  ),
];

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _noteContent = '';
  late WebViewController _webViewController;
  EditorState _editorState = EditorState.initial();

  // Dropdown states
  bool _isHeadingDropdownOpen = false;
  bool _isListDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterWebView',
        onMessageReceived: (JavaScriptMessage message) {
          _handleMessage(message.message);
        },
      );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _webViewController.loadHtmlString(getEditorHtml(_noteContent, isDark));
  }

  void _handleMessage(String message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'content') {
        _noteContent = data['data'];
      } else if (data['type'] == 'selection') {
        setState(() {
          _editorState = EditorState(
            blockType: data['data']['blockType'],
            isBold: data['data']['isBold'],
            isItalic: data['data']['isItalic'],
            isUnordered: data['data']['isUnordered'],
            isOrdered: data['data']['isOrdered'],
          );
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  void _executeCommand(String command, [String? args]) {
    final argsStr = args != null ? "'$args'" : 'null';
    _webViewController.runJavaScript("handleCommand('$command', $argsStr)");
  }

  Future<void> _handleSaveNote() async {
    FocusScope.of(context).unfocus();
    if (_noteContent.trim().isEmpty || _noteContent == '<br>') {
      _showErrorDialog("Empty Note", "Please type something before saving.");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Note'),
          content: const Text('Choose a format to download:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _saveAsText(_noteContent);
              },
              child: const Text('Save as Text (.txt)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showErrorDialog(
                  "Notice",
                  "Save as PDF requires extra plugins in Flutter (like printing). Implemented Text save only.",
                );
              },
              child: const Text('Save as PDF (.pdf)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAsText(String content) async {
    try {
      // Strip HTML tags roughly for text view
      final plainText = content
          .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '\n')
          .trim();
      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/Module_Notes_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(path);
      await file.writeAsString(plainText);
      _showErrorDialog("Success", "Note saved to $path");
    } catch (e) {
      _showErrorDialog("Error", "Failed to save text file.");
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildInline();
  }

  Widget _buildInline() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24 + 48, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: themeExt.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: themeExt.borderColor),
          ),
          child: _buildEditorUI(false),
        ),
      ),
    );
  }

  Widget _buildFullScreen() {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    return Scaffold(
      backgroundColor: themeExt.scaffoldBackgroundColor,
      body: SafeArea(child: _buildEditorUI(true)),
    );
  }

  Widget _buildEditorUI(bool isFull) {
    final themeExt = Theme.of(context).extension<AppDesignExtension>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final currentHeading = headingOptions.firstWhere(
      (h) => h.tag.toLowerCase() == _editorState.blockType.toLowerCase(),
      orElse: () => headingOptions[6], // Default to P
    );

    return Stack(
      children: [
        Column(
          children: [
            // Header / Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: themeExt.skeletonBase,
                border: Border(bottom: BorderSide(color: themeExt.borderColor)),
                borderRadius: isFull
                    ? BorderRadius.zero
                    : const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  // Style Dropdown
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isListDropdownOpen = false;
                        _isHeadingDropdownOpen = !_isHeadingDropdownOpen;
                      });
                    },
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
                          Text(
                            currentHeading.label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 14,
                            color: themeExt.secondaryText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: themeExt.borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  // List Dropdown Toggle
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isHeadingDropdownOpen = false;
                        _isListDropdownOpen = !_isListDropdownOpen;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            _isListDropdownOpen ||
                                _editorState.isUnordered ||
                                _editorState.isOrdered
                            ? themeExt.borderColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _editorState.isOrdered
                            ? Icons.format_list_numbered
                            : Icons.format_list_bulleted,
                        size: 20,
                        color:
                            _editorState.isUnordered || _editorState.isOrdered
                            ? colorScheme.onSurface
                            : themeExt.secondaryText,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: themeExt.borderColor,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),

                  // Bold Toggle
                  InkWell(
                    onTap: () => _executeCommand('format', 'bold'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _editorState.isBold
                            ? themeExt.borderColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'B',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _editorState.isBold
                              ? colorScheme.onSurface
                              : themeExt.secondaryText,
                        ),
                      ),
                    ),
                  ),

                  // Italic Toggle
                  InkWell(
                    onTap: () => _executeCommand('format', 'italic'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _editorState.isItalic
                            ? themeExt.borderColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'I',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: _editorState.isItalic
                              ? colorScheme.onSurface
                              : themeExt.secondaryText,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Fullscreen Toggle
                  InkWell(
                    onTap: () async {
                      if (isFull) {
                        Navigator.pop(context);
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => _buildFullScreen(),
                            fullscreenDialog: true,
                          ),
                        );
                        setState(() {});
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeExt.skeletonBase,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFull ? Icons.fullscreen_exit : Icons.fullscreen,
                        size: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Editor Area
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (_isHeadingDropdownOpen || _isListDropdownOpen) {
                    setState(() {
                      _isHeadingDropdownOpen = false;
                      _isListDropdownOpen = false;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: isFull
                        ? BorderRadius.zero
                        : const BorderRadius.vertical(
                            bottom: Radius.circular(24),
                          ),
                    // Clip hard bounds for Inline
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: WebViewWidget(controller: _webViewController),
                ),
              ),
            ),
          ],
        ),

        // Dropdowns
        if (_isHeadingDropdownOpen)
          Positioned(
            top: 56,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeExt.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: headingOptions.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: themeExt.borderColor),
                  itemBuilder: (context, index) {
                    final option = headingOptions[index];
                    return InkWell(
                      onTap: () {
                        _executeCommand('style', option.tag);
                        setState(() {
                          _isHeadingDropdownOpen = false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: option.style == 'bold'
                                        ? FontWeight.bold
                                        : (option.style == 'semibold'
                                              ? FontWeight.w600
                                              : FontWeight.normal),
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      option.tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      option.desc,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

        if (_isListDropdownOpen)
          Positioned(
            top: 56,
            left: 96,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: themeExt.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeExt.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        _executeCommand('list', 'ul');
                        setState(() => _isListDropdownOpen = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: _editorState.isUnordered
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              Icons.format_list_bulleted,
                              size: 18,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Bulleted list',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (_editorState.isUnordered)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Divider(height: 1, color: themeExt.borderColor),
                    InkWell(
                      onTap: () {
                        _executeCommand('list', 'ol');
                        setState(() => _isListDropdownOpen = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: _editorState.isOrdered
                            ? colorScheme.primaryContainer
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              Icons.format_list_numbered,
                              size: 18,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Numbered list',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (_editorState.isOrdered)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(
                                  Icons.check,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Save Button
        Positioned(
          bottom: 20,
          right: 20,
          child: InkWell(
            onTap: _handleSaveNote,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.save_outlined,
                    color: colorScheme.onPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SAVE',
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
