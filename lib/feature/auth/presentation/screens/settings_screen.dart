import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_durations.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/theme_provider_service.dart';
import '../../../../core/services/injection_container.dart' as di;
import '../../../../core/domain/entities/theme_state.dart';
import '../../../../core/theme/build_context_color_extension.dart';
import '../../../../core/utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _syncEnabled = true;
  late final ThemeProviderService _themeProvider;
  late final AnimationController _themeTransitionController;
  late final Animation<double> _themeTransitionAnimation;

  @override
  void initState() {
    super.initState();
    _themeProvider = di.sl<ThemeProviderService>();

    // Initialize theme transition animation
    _themeTransitionController = AnimationController(
      duration: AppDurations.animMedium,
      vsync: this,
    );
    _themeTransitionAnimation = CurvedAnimation(
      parent: _themeTransitionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _themeTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<ThemeState>(
        stream: _themeProvider.themeStream,
        initialData: _themeProvider.currentTheme,
        builder: (context, themeSnapshot) {
          final themeState = themeSnapshot.data!;

          return AnimatedBuilder(
            animation: _themeTransitionAnimation,
            builder: (context, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Theme Section
                    Text(
                      'Appearance',
                      style: AppTypography.headlineSmall.copyWith(
                        color: context.onSurfacePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildSettingsCard([
                      _buildThemeSelectionTile(themeState),
                      const Divider(height: 1),
                      _buildSystemThemeTile(themeState),
                      const Divider(height: 1),
                      _buildThemePreviewTile(),
                    ]),

                    const SizedBox(height: AppSpacing.xl),

                    // App Preferences Section
                    Text(
                      'App Preferences',
                      style: AppTypography.headlineSmall.copyWith(
                        color: context.onSurfacePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Receive task reminders and updates',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      const Divider(height: 1),
                      _buildSwitchTile(
                        icon: Icons.sync,
                        title: 'Auto Sync',
                        subtitle: 'Automatically sync data when online',
                        value: _syncEnabled,
                        onChanged: (value) {
                          setState(() {
                            _syncEnabled = value;
                          });
                        },
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.xl),

                    // Data & Privacy Section
                    Text(
                      'Data & Privacy',
                      style: AppTypography.headlineSmall.copyWith(
                        color: context.onSurfacePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildSettingsCard([
                      _buildActionTile(
                        icon: Icons.import_export,
                        title: 'Export / Import Data',
                        subtitle: 'Backup or restore your tasks',
                        onTap: () {
                          context.push('/export-import');
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        icon: Icons.delete_sweep,
                        title: 'Clear Cache',
                        subtitle: 'Clear locally stored data',
                        onTap: () {
                          _showClearCacheDialog(context);
                        },
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.xl),

                    // About Section
                    Text(
                      'About',
                      style: AppTypography.headlineSmall.copyWith(
                        color: context.onSurfacePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    _buildSettingsCard([
                      _buildActionTile(
                        icon: Icons.info,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        onTap: null,
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        icon: Icons.privacy_tip,
                        title: 'Privacy Policy',
                        subtitle: 'View our privacy policy',
                        onTap: () {
                          _showPrivacyPolicy(context);
                        },
                      ),
                      const Divider(height: 1),
                      _buildActionTile(
                        icon: Icons.description,
                        title: 'Terms of Service',
                        subtitle: 'View terms and conditions',
                        onTap: () {
                          _showTermsOfService(context);
                        },
                      ),
                    ]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: context.onSurfaceSecondary.withValues(alpha: 0.1),
            blurRadius: AppDimensions.radiusSm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildThemeSelectionTile(ThemeState themeState) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: AppDimensions.avatarSizeSmall,
        height: AppDimensions.avatarSizeSmall,
        decoration: BoxDecoration(
          color: context.ongoingTaskColor.withValues(alpha: 0.1),
          borderRadius:
              BorderRadius.circular(AppDimensions.avatarSizeSmall / 2),
        ),
        child: Icon(
          _getThemeIcon(themeState.currentTheme.mode),
          color: context.ongoingTaskColor,
          size: AppDimensions.iconSize,
        ),
      ),
      title: Text(
        'Theme',
        style: AppTypography.titleMedium.copyWith(
          color: context.onSurfacePrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getThemeDisplayName(themeState.currentTheme.mode),
        style: AppTypography.bodySmall.copyWith(
          color: context.onSurfaceSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeSelectionDialog(context, themeState),
    );
  }

  Widget _buildSystemThemeTile(ThemeState themeState) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.ongoingTaskColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.settings_system_daydream,
          color: context.ongoingTaskColor,
          size: 20,
        ),
      ),
      title: Text(
        'Follow System Theme',
        style: AppTypography.titleMedium.copyWith(
          color: context.onSurfacePrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Automatically switch between light and dark themes',
        style: AppTypography.bodySmall.copyWith(
          color: context.onSurfaceSecondary,
        ),
      ),
      trailing: Switch(
        value: themeState.isSystemThemeEnabled,
        onChanged: (value) => _toggleSystemTheme(value),
      ),
    );
  }

  Widget _buildThemePreviewTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.ongoingTaskColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.preview,
          color: context.ongoingTaskColor,
          size: 20,
        ),
      ),
      title: Text(
        'Theme Preview',
        style: AppTypography.titleMedium.copyWith(
          color: context.onSurfacePrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Preview different themes before applying',
        style: AppTypography.bodySmall.copyWith(
          color: context.onSurfaceSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemePreviewDialog(context),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.ongoingTaskColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: context.ongoingTaskColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: context.onSurfacePrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: context.onSurfaceSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.ongoingTaskColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: context.ongoingTaskColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: context.onSurfacePrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: context.onSurfaceSecondary,
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.chevron_right,
              color: context.onSurfaceSecondary,
            )
          : null,
      onTap: onTap,
    );
  }

  // Theme-related methods
  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }

  String _getThemeDisplayName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
      case ThemeMode.system:
        return 'System Theme';
    }
  }

  Future<void> _toggleSystemTheme(bool enabled) async {
    await _themeTransitionController.forward();

    final result = await _themeProvider.toggleSystemTheme(enabled);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update system theme: ${failure.message}'),
            backgroundColor: context.canceledTaskColor,
          ),
        );
      },
      (_) {
        // Success - animation will complete automatically
      },
    );

    await _themeTransitionController.reverse();
  }

  Future<void> _changeTheme(String themeName) async {
    await _themeTransitionController.forward();

    final result = await _themeProvider.setTheme(themeName);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change theme: ${failure.message}'),
            backgroundColor: context.canceledTaskColor,
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to $themeName'),
            backgroundColor: context.completedTaskColor,
          ),
        );
      },
    );

    await _themeTransitionController.reverse();
  }

  void _showThemeSelectionDialog(BuildContext context, ThemeState themeState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceSecondary,
        title: Text(
          'Select Theme',
          style: AppTypography.headlineSmall.copyWith(
            color: context.onSurfacePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context: dialogContext,
              mode: ThemeMode.light,
              currentMode: themeState.currentTheme.mode,
              onTap: () {
                Navigator.of(dialogContext).pop();
                _changeTheme('Light');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildThemeOption(
              context: dialogContext,
              mode: ThemeMode.dark,
              currentMode: themeState.currentTheme.mode,
              onTap: () {
                Navigator.of(dialogContext).pop();
                _changeTheme('Dark');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildThemeOption(
              context: dialogContext,
              mode: ThemeMode.system,
              currentMode: themeState.currentTheme.mode,
              onTap: () {
                Navigator.of(dialogContext).pop();
                _changeTheme('System');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: context.onSurfaceSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.mdSm),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? this.context.ongoingTaskColor
                : this.context.onSurfacePrimaryOpacity40,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          color: isSelected
              ? this.context.ongoingTaskColor.withValues(alpha: 0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getThemeIcon(mode),
              color: isSelected
                  ? this.context.ongoingTaskColor
                  : this.context.onSurfaceSecondary,
            ),
            const SizedBox(width: AppSpacing.mdSm),
            Expanded(
              child: Text(
                _getThemeDisplayName(mode),
                style: AppTypography.titleMedium.copyWith(
                  color: isSelected
                      ? this.context.ongoingTaskColor
                      : this.context.onSurfacePrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: this.context.ongoingTaskColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _showThemePreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceSecondary,
        title: Text(
          'Theme Preview',
          style: AppTypography.headlineSmall.copyWith(
            color: context.onSurfacePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemePreviewCard('Light Theme', ThemeMode.light),
              const SizedBox(height: AppSpacing.mdSm),
              _buildThemePreviewCard('Dark Theme', ThemeMode.dark),
              const SizedBox(height: AppSpacing.mdSm),
              _buildThemePreviewCard('System Theme', ThemeMode.system),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: AppTypography.labelLarge.copyWith(
                color: context.ongoingTaskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemePreviewCard(String themeName, ThemeMode mode) {
    // Create a mini preview of what the theme would look like
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final previewBg = isDark
        ? AppColors.themePreviewDarkBackground
        : AppColors.themePreviewLightBackground;
    final previewText = isDark
        ? AppColors.themePreviewDarkText
        : AppColors.themePreviewLightText;
    final previewAccent = context.ongoingTaskColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.mdSm),
      decoration: BoxDecoration(
        color: previewBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        border: Border.all(color: context.onSurfacePrimaryOpacity40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimensions.iconSize,
                height: AppDimensions.iconSize,
                decoration: BoxDecoration(
                  color: previewAccent,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.iconSize / 2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                themeName,
                style: TextStyle(
                  color: previewText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: AppDimensions.progressBarHeight,
            decoration: BoxDecoration(
              color: previewText.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              color: previewText.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceSecondary,
        title: Text(
          'Clear Cache',
          style: AppTypography.headlineSmall.copyWith(
            color: context.onSurfacePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will clear all locally stored data. You will need to sync with the server when you go online.',
          style: AppTypography.bodyMedium.copyWith(
            color: context.onSurfaceSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: context.onSurfaceSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully'),
                  backgroundColor: context.completedTaskColor,
                ),
              );
            },
            child: Text(
              'Clear',
              style: AppTypography.labelLarge.copyWith(
                color: context.ongoingTaskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceSecondary,
        title: Text(
          'Privacy Policy',
          style: AppTypography.headlineSmall.copyWith(
            color: context.onSurfacePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'This is a sample privacy policy. In a real application, this would contain the actual privacy policy text explaining how user data is collected, used, and protected.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.onSurfaceSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: AppTypography.labelLarge.copyWith(
                color: context.ongoingTaskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.surfaceSecondary,
        title: Text(
          'Terms of Service',
          style: AppTypography.headlineSmall.copyWith(
            color: context.onSurfacePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'This is a sample terms of service. In a real application, this would contain the actual terms and conditions for using the application.',
            style: AppTypography.bodyMedium.copyWith(
              color: context.onSurfaceSecondary,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Close',
              style: AppTypography.labelLarge.copyWith(
                color: context.ongoingTaskColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
