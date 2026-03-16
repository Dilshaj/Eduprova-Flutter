// Widget _buildField(
//   String label,
//   TextEditingController controller,
//   String hint, {
//   // ThemeData theme,
//   // AppDesignExtension themeExt,
//   TextInputType? keyboardType,
// }) {
//   return Column(
//     crossAxisAlignment: .start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//       ),
//       const SizedBox(height: 8),
//       TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           hintText: hint,
//           hintStyle: TextStyle(
//             color: themeExt.secondaryText.withValues(alpha: 0.5),
//           ),
//           filled: true,
//           fillColor: themeExt.cardColor,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: themeExt.borderColor),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: themeExt.borderColor),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: theme.colorScheme.primary),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 12,
//           ),
//         ),
//       ),
//     ],
//   );
// }

import 'dart:math';

import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';

class BasicInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  // Optional
  final TextInputType? keyboardType;
  final int? maxLines;

  const BasicInput({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,

    // optional
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: themeExt.secondaryText.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: themeExt.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: themeExt.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
