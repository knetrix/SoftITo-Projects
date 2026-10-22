import 'package:flutter/material.dart';
import 'core/services/storage_service.dart';
import 'core/services/ai_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/user_model.dart';
import 'features/auth/views/login_view.dart';
import 'features/habits/controllers/habits_controller.dart';
import 'features/statistics/controllers/statistics_controller.dart';
import 'features/community/controllers/community_controller.dart';
import 'features/profile/controllers/profile_controller.dart';
import 'features/home/views/home_nav_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.getInstance();
  final aiService = AIService();
  await NotificationService().init();

  runApp(RutinoApp(
    storageService: storageService,
    aiService: aiService,
  ));
}

class RutinoApp extends StatefulWidget {
  final StorageService storageService;
  final AIService aiService;

  const RutinoApp({
    super.key,
    required this.storageService,
    required this.aiService,
  });

  @override
  State<RutinoApp> createState() => _RutinoAppState();
}

class _RutinoAppState extends State<RutinoApp> {
  late final AuthController _authController;
  late final HabitsController _habitsController;
  late final StatisticsController _statsController;
  late final CommunityController _communityController;
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    AppStrings.setLanguage(widget.storageService.loadLanguage());

    _authController = AuthController(widget.storageService);
    _profileController = ProfileController(widget.storageService);
    _habitsController = HabitsController(
      widget.storageService,
      onPointsChanged: (diff) => _profileController.addPoints(diff),
    );
    _statsController = StatisticsController(widget.storageService, widget.aiService);
    _communityController = CommunityController(widget.storageService);

    _profileController.languageNotifier.addListener(() {
      _statsController.showInsightFor(_profileController.languageNotifier.value);
    });

    _authController.userNotifier.addListener(() {
      _profileController.syncUser(_authController.userNotifier.value);
    });
  }

  @override
  void dispose() {
    _authController.dispose();
    _habitsController.dispose();
    _statsController.dispose();
    _communityController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _profileController.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: _profileController.languageNotifier,
          builder: (context, lang, _) {
            AppStrings.setLanguage(lang);
            return MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              home: _buildHomeRouter(),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeRouter() {
    return ValueListenableBuilder<UserModel?>(
      valueListenable: _authController.userNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return LoginView(
            authController: _authController,
            onLoginSuccess: () {},
          );
        }
        return HomeNavView(
          habitsController: _habitsController,
          statsController: _statsController,
          communityController: _communityController,
          profileController: _profileController,
          onLogout: () => _authController.logout(),
        );
      },
    );
  }
}
