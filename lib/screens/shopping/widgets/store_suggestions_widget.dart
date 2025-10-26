import 'package:flutter/material.dart';
import 'dart:ui';

class StoreSuggestionsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> suggestedStores;
  final bool isCompact;

  const StoreSuggestionsWidget({
    super.key,
    required this.suggestedStores,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Suggested Stores',
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          // Main shadow for depth
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black.withValues(alpha: 0.4),
                          ),
                          // Secondary shadow for more depth
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black.withValues(alpha: 0.6),
                          ),
                          // Highlight shadow for 3D effect
                          Shadow(
                            offset: const Offset(-1, -1),
                            blurRadius: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Store cards
              ...(suggestedStores.map((store) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3748),
                                shadows: [
                                  // Main shadow for depth
                                  Shadow(
                                    offset: const Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                  // Highlight shadow for 3D effect
                                  Shadow(
                                    offset: const Offset(-0.5, -0.5),
                                    blurRadius: 1,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFF667eea).withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        store['reason'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                          shadows: [
                            // Subtle shadow for depth
                            Shadow(
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1,
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                      ),
                      if ((store['categories'] as List).isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: (store['categories'] as List<String>).map((category) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF667eea).withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF667eea),
                                  shadows: [
                                    // Subtle shadow for 3D effect
                                    Shadow(
                                      offset: const Offset(0.5, 0.5),
                                      blurRadius: 1,
                                      color: Colors.black.withValues(alpha: 0.2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                );
              })),
            ],
          ),
        ),
      ),
    );
  }
}
