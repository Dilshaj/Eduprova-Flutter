import 'package:flutter/material.dart';

class AiAvatarWidget extends StatelessWidget {
  final bool isMale;

  const AiAvatarWidget({super.key, required this.isMale});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          alignment: .center,
          children: [
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: .circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
            ),
            Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: .circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            Positioned(
              top: 25,
              left: 100,
              child: _buildGlowingDot(const Color(0xFF2962FF)),
            ),
            Positioned(
              bottom: 50,
              right: 40,
              child: _buildGlowingDot(const Color(0xFF2962FF)),
            ),
            Positioned(
              bottom: 20,
              left: 120,
              child: _buildGlowingDot(const Color(0xFF2962FF)),
            ),
            Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: .circle,
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 50,
              child: _buildGlowingDot(const Color(0xFFD500F9)),
            ),
            Positioned(
              bottom: 70,
              left: 40,
              child: _buildGlowingDot(const Color(0xFF3B82F6)),
            ),
            Container(
              width: 154,
              height: 154,
              decoration: BoxDecoration(
                shape: .circle,
                boxShadow: [
                  .new(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(-10, 0),
                  ),
                  .new(
                    color: const Color(0xFFD946EF).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(10, 0),
                  ),
                ],
              ),
            ),
            Container(
              width: 154,
              height: 154,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(shape: .circle),
              child: Container(
                decoration: const BoxDecoration(
                  shape: .circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    isMale
                        ? 'assets/ai/ai-male.png'
                        : 'assets/ai/ai-female.png',
                    fit: .cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue.shade50,
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowingDot(Color color) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
