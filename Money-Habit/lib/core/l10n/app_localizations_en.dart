// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Habit Tracker';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navChallenge => 'Challenge';

  @override
  String get navGoals => 'My Goals';

  @override
  String get navExpenses => 'Expenses';

  @override
  String get navBudget => 'Budget';

  @override
  String get registerTitle => 'Register';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone Number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get registerButton => 'Create Account';

  @override
  String get loginButton => 'Sign In';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get loginHere => 'Sign In';

  @override
  String get registerHere => 'Register';

  @override
  String get quickLogin => 'Quick Login (Test User)';

  @override
  String get quickLoginHint => 'Sign in with a demo test user in one tap';

  @override
  String get loginFailed => 'Invalid email or password';

  @override
  String get userAlreadyExists => 'A user with this email already exists';

  @override
  String get errorRequired => 'This field is required';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address';

  @override
  String get errorInvalidPhone =>
      'Please enter a 10-digit phone number starting with 5';

  @override
  String get errorWeakPassword =>
      'Must contain at least 8 characters, 1 uppercase, 1 lowercase, and 1 number';

  @override
  String get errorPasswordMismatch => 'Passwords do not match';

  @override
  String get errorInvalidAmount => 'Please enter a valid amount';

  @override
  String get errorIncorrectPassword => 'Current password is incorrect';

  @override
  String get dashboardWelcome => 'Welcome';

  @override
  String get dashboardRemainingBudget => 'Remaining Budget This Month';

  @override
  String get dashboardTodayChallenge => 'Today\'s Challenge Task';

  @override
  String get dashboardStreak => 'Streak';

  @override
  String dashboardDaysStreak(Object count) {
    return '$count Day Streak';
  }

  @override
  String get dashboardNearestGoal => 'Nearest Goal';

  @override
  String get dashboardRecentExpenses => 'Recent Expenses';

  @override
  String get dashboardNoExpenses => 'No expense records yet';

  @override
  String get dashboardNoChallenge => 'No active challenge';

  @override
  String get dashboardNoGoal => 'No financial goals yet';

  @override
  String get dashboardStartChallenge => 'Start Challenge';

  @override
  String get dashboardAddGoal => 'Add Goal';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get challengeTitle => '10-Day Challenge';

  @override
  String get challengeStartPrompt =>
      'Start the 10-Day Financial Awareness Challenge!';

  @override
  String get challengeStartButton => 'Start New Challenge';

  @override
  String get challengeRestartButton => 'Restart Challenge';

  @override
  String get challengeCompletedTitle => 'Congratulations! 🎉';

  @override
  String get challengeCompletedMessage =>
      'You have completed the 10-day financial challenge! You\'ve formed a great habit.';

  @override
  String challengeDay(Object day) {
    return 'Day $day';
  }

  @override
  String challengeDaysCounter(Object current) {
    return '$current/10 Days';
  }

  @override
  String challengeCurrentStreak(Object count) {
    return 'Current Streak: $count days';
  }

  @override
  String challengeBestStreak(Object count) {
    return 'Best Streak: $count days';
  }

  @override
  String get challengeTodayTask => 'Today\'s Task';

  @override
  String get challengeLocked => 'Locked (Not today)';

  @override
  String get challengeMissed => 'Missed';

  @override
  String get challengeCompleteButton => 'Complete Task';

  @override
  String get challengeCompletedTask => 'Completed';

  @override
  String get goalsTitle => 'Financial Goals';

  @override
  String get goalsEmpty =>
      'No goals yet. Create a new goal to start saving money!';

  @override
  String get goalsAdd => 'Add New Goal';

  @override
  String get goalsNewTitle => 'Goal Title';

  @override
  String get goalsTargetAmount => 'Target Amount';

  @override
  String get goalsSavedAmount => 'Saved Amount';

  @override
  String get goalsProgress => 'Progress';

  @override
  String get goalsAddStep => 'Add Money';

  @override
  String get goalsStepAmount => 'Amount to Add';

  @override
  String get goalsStepNote => 'Note (Optional)';

  @override
  String get goalsCompletedBadge => 'Completed 🎯';

  @override
  String get goalsDelete => 'Delete Goal';

  @override
  String get goalsDeleteConfirm =>
      'Are you sure you want to delete this goal and its saving steps?';

  @override
  String get goalsStepsHistory => 'Progress History';

  @override
  String get goalsNoSteps => 'No saving steps added yet.';

  @override
  String get expensesTitle => 'Expense Log';

  @override
  String get expensesEmpty => 'No expenses recorded in this period.';

  @override
  String get expensesAdd => 'Add Expense';

  @override
  String get expensesNewTitle => 'New Expense';

  @override
  String get expensesAmount => 'Amount';

  @override
  String get expensesCategory => 'Category';

  @override
  String get expensesDate => 'Date';

  @override
  String get expensesNote => 'Note (Optional)';

  @override
  String get expensesDelete => 'Delete Expense';

  @override
  String get expensesDeletedMessage => 'Expense deleted';

  @override
  String get expensesUndo => 'Undo';

  @override
  String get expensesMonthFilter => 'Select Month';

  @override
  String get categoryMarket => 'Market & Groceries';

  @override
  String get categoryTransport => 'Transportation';

  @override
  String get categoryBills => 'Bills & Utilities';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryHealth => 'Healthcare';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryOther => 'Other';

  @override
  String get budgetTitle => 'Budget & Stats';

  @override
  String get budgetMonthlyLimit => 'Monthly Budget Limit';

  @override
  String get budgetSetLimit => 'Set Limit';

  @override
  String get budgetSpent => 'Spent';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String get budgetOverBudget => 'Over Budget!';

  @override
  String get budgetCategoryDistribution => 'Category Distribution';

  @override
  String get budgetWeeklyExpenses => 'Last 7 Days Expenses';

  @override
  String get budgetLimitInput => 'New Budget Limit';

  @override
  String get budgetNoCategoryData => 'No expense data for chart';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsTheme => 'Appearance & Theme';

  @override
  String get settingsThemeDark => 'Dark Theme (Default)';

  @override
  String get settingsThemeLight => 'Light Theme';

  @override
  String get settingsLanguage => 'App Language';

  @override
  String get settingsLangTr => 'Türkçe';

  @override
  String get settingsLangEn => 'English';

  @override
  String get settingsAccountUpdate => 'Update Account Information';

  @override
  String get settingsUpdateSuccess =>
      'Account information updated successfully';

  @override
  String get settingsLogout => 'Sign Out';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get settingsPickAvatar => 'Choose Profile Picture';

  @override
  String get settingsAvatarPreset => 'Preset Avatars';

  @override
  String get settingsAvatarGallery => 'Choose from Gallery';

  @override
  String get settingsAvatarCamera => 'Take a Photo';

  @override
  String settingsRegisteredAt(Object date) {
    return 'Registered on: $date';
  }

  @override
  String get settingsCurrentPassword => 'Current Password';

  @override
  String get settingsNewPassword => 'New Password';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';
}
