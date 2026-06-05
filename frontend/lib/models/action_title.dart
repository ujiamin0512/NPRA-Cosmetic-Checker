import 'package:flutter/material.dart';

class ActionTile {
  ActionTile({
    required this.title,
    this.icon,
    this.svgAsset,
    required this.iconColor,
    required this.iconBackground,
    required this.color,
  });

  final String title;
  final IconData? icon;
  final String? svgAsset;
  final Color iconColor;
  final Color iconBackground;
  final Color color;

  static List<ActionTile> getAllActionTitle() {
    return <ActionTile>[
      ActionTile(
        title: 'Canceled Cosmetic Notification List',
        icon: Icons.cancel,
        iconColor: const Color(0xFFD42222),
        iconBackground: const Color(0xFFFDE9E9),
        color: const Color(0xFFF1F4FF),
      ),
      ActionTile(
        title: 'Notified Cosmetic List',
        icon: Icons.check_circle,
        iconColor: const Color(0xFF33BE66),
        iconBackground: const Color(0xFFE9F9F2),
        color: const Color(0xFFF1F4FF),
      ),
    ];
  }
}
