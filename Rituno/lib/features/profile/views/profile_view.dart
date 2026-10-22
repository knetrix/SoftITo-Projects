import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';
import '../../auth/models/user_model.dart';
import '../widgets/profile_header_card_widget.dart';
import '../widgets/profile_setting_tile_widget.dart';
import '../widgets/edit_profile_dialog.dart';
import '../../../core/constants/app_strings.dart';

class ProfileView extends StatelessWidget {
  final ProfileController profileController;
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.profileController,
    required this.onLogout,
  });

  void _showEditProfile(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        user: user,
        onSave: (name, email, phone) {
          profileController.updateUserProfile(name: name, email: email, phone: phone);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profileTitle),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<UserModel?>(
          valueListenable: profileController.userNotifier,
          builder: (context, user, _) {
            if (user == null) {
              return Center(child: Text(AppStrings.userNotFound));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  ProfileHeaderCardWidget(
                    user: user,
                    onEditPressed: () => _showEditProfile(context, user),
                  ),
                  const SizedBox(height: 20),
                  _buildThemeSettingTile(),
                  _buildLanguageSettingTile(context),
                  _buildRankInfoTile(user),
                  _buildVersionTile(),
                  const SizedBox(height: 12),
                  _buildLogoutTile(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThemeSettingTile() {
    return ValueListenableBuilder<bool>(
      valueListenable: profileController.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return ProfileSettingTileWidget(
          icon: Icons.dark_mode_outlined,
          title: AppStrings.themeMode,
          subtitle: isDark ? AppStrings.themeDarkSubtitle : AppStrings.themeLightSubtitle,
          trailing: Switch(
            value: isDark,
            onChanged: (val) => profileController.toggleDarkMode(val),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettingTile(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: profileController.languageNotifier,
      builder: (context, lang, _) {
        return ProfileSettingTileWidget(
          icon: Icons.language_rounded,
          title: AppStrings.language,
          subtitle: lang == 'tr' ? AppStrings.trLanguage : AppStrings.enLanguage,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageSelection(context, lang),
        );
      },
    );
  }

  void _showLanguageSelection(BuildContext context, String currentLang) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppStrings.trLanguage),
              trailing: currentLang == 'tr' ? const Icon(Icons.check) : null,
              onTap: () {
                profileController.setLanguage('tr');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(AppStrings.enLanguage),
              trailing: currentLang == 'en' ? const Icon(Icons.check) : null,
              onTap: () {
                profileController.setLanguage('en');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankInfoTile(UserModel user) {
    return ProfileSettingTileWidget(
      icon: Icons.military_tech_rounded,
      title: AppStrings.currentRankTile,
      subtitle: user.currentRank,
    );
  }

  Widget _buildVersionTile() {
    return ProfileSettingTileWidget(
      icon: Icons.info_outline_rounded,
      title: AppStrings.appVersionTile,
      subtitle: 'v1.0.0 (Material 3)',
    );
  }

  Widget _buildLogoutTile() {
    return ProfileSettingTileWidget(
      icon: Icons.logout_rounded,
      title: AppStrings.logout,
      onTap: onLogout,
    );
  }
}
