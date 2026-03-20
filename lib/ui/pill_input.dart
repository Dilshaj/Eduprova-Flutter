import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PillInput extends StatefulWidget {
  final List<String> initialValues;
  final Function(List<String>) onChanged;
  final String placeholder;
  final Color? color;

  const PillInput({
    super.key,
    this.initialValues = const [],
    required this.onChanged,
    this.placeholder = 'Add tech stack...',
    this.color,
  });

  @override
  State<PillInput> createState() => _PillInputState();
}

class _PillInputState extends State<PillInput> {
  late List<String> _pills;
  final TextEditingController _controller = .new();
  final FocusNode _focusNode = .new();

  @override
  void initState() {
    super.initState();
    _pills = .from(widget.initialValues);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _addPill(_controller.text);
    }
  }

  void _addPill(String value) {
    final trimmed = value.trim().replaceAll(',', '');
    if (trimmed.isNotEmpty && !_pills.contains(trimmed)) {
      setState(() {
        _pills.add(trimmed);
        _controller.clear();
      });
      widget.onChanged(_pills);
    } else {
      _controller.clear();
    }
  }

  void _removePill(String value) {
    setState(() {
      _pills.remove(value);
    });
    widget.onChanged(_pills);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = context.design;
    final activeColor = widget.color ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          padding: .symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: themeExt.borderColor.withValues(alpha: 0.1),
            borderRadius: .circular(16),
            border: .all(color: themeExt.borderColor),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: (val) {
              _addPill(val);
              _focusNode.requestFocus();
            },
            onChanged: (val) {
              if (val.endsWith(',')) {
                _addPill(val);
                _focusNode.requestFocus();
              }
            },
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: .new(
                color: themeExt.secondaryText.withValues(alpha: 0.5),
                fontSize: 14,
              ),
              border: InputBorder.none,
              isDense: true,
            ),
            style: .new(fontSize: 16, color: theme.colorScheme.onSurface),
          ),
        ),
        if (_pills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final pill in _pills)
                Container(
                  padding: .only(left: 12, right: 8, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.1),
                    borderRadius: .circular(20),
                    border: .all(color: activeColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        pill,
                        style: .new(
                          fontSize: 12,
                          fontWeight: .w600,
                          color: activeColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removePill(pill),
                        child: Icon(
                          LucideIcons.x,
                          size: 14,
                          color: activeColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
