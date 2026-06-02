import 'package:flutter/material.dart';
import '../models/moderation_result.dart';
import '../../../../app/theme/app_colors.dart';

class SafetyBadge extends StatelessWidget {
  final ModerationStatus status;

  const SafetyBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    IconData badgeIcon;
    String tooltipText;

    switch (status) {
      case ModerationStatus.safe:
        badgeColor = AppColors.success;
        badgeIcon = Icons.shield_rounded;
        tooltipText = 'Analyzed by SafeChat AI: Safe';
        break;
      case ModerationStatus.warning:
        badgeColor = AppColors.warning;
        badgeIcon = Icons.warning_rounded;
        tooltipText = 'Analyzed by SafeChat AI: Warning';
        break;
      case ModerationStatus.blocked:
        badgeColor = AppColors.error;
        badgeIcon = Icons.gpp_bad_rounded;
        tooltipText = 'Analyzed by SafeChat AI: Blocked';
        break;
    }

    return Tooltip(
      message: tooltipText,
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(
        badgeIcon,
        color: badgeColor,
        size: 16,
      ),
    );
  }
}
