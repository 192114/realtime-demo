import 'package:flutter/material.dart';
import 'package:native_app/config/theme/app_colors.dart';
import 'package:native_app/config/theme/app_spacing.dart';
import 'package:native_app/config/theme/app_typography.dart';

/// 离线提示条：实时连接断开时显示，点击立即重试
class ChatOfflineBanner extends StatelessWidget {
  const ChatOfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.errorContainer,
      child: InkWell(
        onTap: onRetry,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.wifi_off, size: 16, color: AppColors.onErrorContainer),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '实时连接已断开，正在自动重试；点击立即重试',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

