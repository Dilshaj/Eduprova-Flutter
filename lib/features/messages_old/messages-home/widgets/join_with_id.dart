import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JoinWithIdScreen extends StatefulWidget {
  const JoinWithIdScreen({super.key});

  @override
  State<JoinWithIdScreen> createState() => _JoinWithIdScreenState();
}

class _JoinWithIdScreenState extends State<JoinWithIdScreen> {
  String code = '';

  void handlePress(String val) {
    if (code.length < 9) {
      setState(() => code = code + val);
    }
  }

  void handleDelete() {
    if (code.isNotEmpty) {
      setState(() => code = code.substring(0, code.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final btnWidth = (screenWidth - 40 - 32) / 3;
    final formattedCode = code.split('').join(' ');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      size: 28,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Join with ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Enter the meeting ID or code provided by the organizer',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Code display
                    Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formattedCode,
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF111111),
                              letterSpacing: 4,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 32,
                            color: const Color(0xFF0066FF),
                            margin: const EdgeInsets.only(left: 4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Expanded(child: SizedBox()),

                    // Join button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0066FF), Color(0xFFE056FD)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0066FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'Join Now',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Keypad
            Container(
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  _buildKeyRow(['1', '2', '3'], btnWidth, isDeleteRow: false),
                  const SizedBox(height: 16),
                  _buildKeyRow(['4', '5', '6'], btnWidth, isDeleteRow: false),
                  const SizedBox(height: 16),
                  _buildKeyRow(['7', '8', '9'], btnWidth, isDeleteRow: false),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: btnWidth),
                      _KeyButton(
                        label: '0',
                        width: btnWidth,
                        onTap: () => handlePress('0'),
                      ),
                      _KeyButton(
                        isDelete: true,
                        width: btnWidth,
                        onTap: handleDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyRow(
    List<String> keys,
    double btnWidth, {
    required bool isDeleteRow,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys
          .map(
            (k) => _KeyButton(
              label: k,
              width: btnWidth,
              onTap: () => handlePress(k),
            ),
          )
          .toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final bool isDelete;
  final double width;
  final VoidCallback onTap;

  const _KeyButton({
    this.label,
    this.isDelete = false,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isDelete
            ? const Icon(
                Icons.backspace_outlined,
                size: 28,
                color: Color(0xFF4B5563),
              )
            : Text(
                label!,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
      ),
    );
  }
}
