import 'package:flutter/material.dart';

enum ProfileBadgeType { verified, paid, pending, new_, premium, locked }

class StatusBadgeWidget extends StatelessWidget {
  final ProfileBadgeType type;
  final String? customLabel;

  const StatusBadgeWidget({super.key, required this.type, this.customLabel});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 10, color: config.textColor),
          const SizedBox(width: 3),
          Text(
            customLabel ?? config.label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: config.textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (type) {
      case ProfileBadgeType.verified:
        return _BadgeConfig(
          bgColor: const Color(0xFF0D3D22),
          borderColor: const Color(0xFF2D7A4F),
          textColor: const Color(0xFF4ADE80),
          icon: Icons.verified_rounded,
          label: 'Verified',
        );
      case ProfileBadgeType.paid:
        return _BadgeConfig(
          bgColor: const Color(0xFF1A2D10),
          borderColor: const Color(0xFF2D7A4F),
          textColor: const Color(0xFF4ADE80),
          icon: Icons.check_circle_rounded,
          label: 'Paid',
        );
      case ProfileBadgeType.pending:
        return _BadgeConfig(
          bgColor: const Color(0xFF2D1A00),
          borderColor: const Color(0xFFB45309),
          textColor: const Color(0xFFFBBF24),
          icon: Icons.schedule_rounded,
          label: 'Pending',
        );
      case ProfileBadgeType.new_:
        return _BadgeConfig(
          bgColor: const Color(0xFF1A0A30),
          borderColor: const Color(0xFF7C3AED),
          textColor: const Color(0xFFA78BFA),
          icon: Icons.fiber_new_rounded,
          label: 'New',
        );
      case ProfileBadgeType.premium:
        return _BadgeConfig(
          bgColor: const Color(0xFF2D1A00),
          borderColor: const Color(0xFFE8A87C),
          textColor: const Color(0xFFE8A87C),
          icon: Icons.star_rounded,
          label: 'Premium',
        );
      case ProfileBadgeType.locked:
        return _BadgeConfig(
          bgColor: const Color(0xFF1A0A10),
          borderColor: const Color(0xFFC8556A),
          textColor: const Color(0xFFC8556A),
          icon: Icons.lock_rounded,
          label: 'Locked',
        );
    }
  }
}

class _BadgeConfig {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;
  final String label;
  const _BadgeConfig({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
    required this.label,
  });
}
