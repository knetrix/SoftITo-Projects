// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get readerTitle => 'Reader';

  @override
  String get appName => 'Kitalog';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonClose => 'Close';

  @override
  String get commonOk => 'OK';

  @override
  String get commonUndo => 'Undo';

  @override
  String get errorRequired => 'This field is required.';

  @override
  String get errorEmailInvalid => 'Enter a valid email address.';

  @override
  String get errorPhoneInvalid =>
      'Phone must start with 0, have 11 digits and match 0 (5XX) XXX XX XX.';

  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters.';

  @override
  String get errorPasswordUppercase =>
      'Password must contain an uppercase letter.';

  @override
  String get errorPasswordLowercase =>
      'Password must contain a lowercase letter.';

  @override
  String get errorPasswordDigit => 'Password must contain a digit.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get genreNovel => 'Novel';

  @override
  String get genreScience => 'Science';

  @override
  String get genreHistory => 'History';

  @override
  String get genrePhilosophy => 'Philosophy';

  @override
  String get genrePersonalDevelopment => 'Personal Development';

  @override
  String get genreSciFiFantasy => 'Sci-Fi & Fantasy';

  @override
  String get genreBiography => 'Biography';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get genreChildren => 'Children';

  @override
  String get genreOther => 'Other';

  @override
  String get statusToRead => 'To read';

  @override
  String get statusReading => 'Reading';

  @override
  String get statusFinished => 'Finished';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String pageProgress(int current, int total) {
    return '$current / $total pages';
  }

  @override
  String progressPercent(int percent) {
    return '$percent%';
  }

  @override
  String progressSemantics(int percent) {
    return 'Reading progress $percent percent';
  }

  @override
  String ratingStarSemantics(int star) {
    return 'Rate $star stars';
  }

  @override
  String get splashError => 'Data could not be loaded.';

  @override
  String get authTagline => 'Your virtual library, in your pocket.';

  @override
  String get registerTitle => 'Create account';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Phone';

  @override
  String get hintPhone => '0 (5XX) XXX XX XX';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Confirm password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get buttonRegister => 'Sign up';

  @override
  String get buttonLogin => 'Sign in';

  @override
  String get linkHaveAccount => 'Already have an account? Sign in';

  @override
  String get linkNoAccount => 'No account yet? Sign up';

  @override
  String get linkForgotPassword => 'Forgot password?';

  @override
  String get forgotTitle => 'Reset Password';

  @override
  String get forgotVerifyInfo =>
      'Enter the email address and phone number you used when signing up.';

  @override
  String get forgotVerifyButton => 'Continue';

  @override
  String get forgotBackToLogin => 'Back to sign in';

  @override
  String forgotNewPasswordInfo(String email) {
    return 'Account $email verified. Choose a new password.';
  }

  @override
  String get forgotResetButton => 'Update Password';

  @override
  String get forgotBack => 'Back';

  @override
  String get forgotSuccess =>
      'Your password was updated. You can sign in with your new password.';

  @override
  String get errorRecoveryMismatch =>
      'The email or phone number doesn\'t match our records.';

  @override
  String errorTooManyAttempts(int seconds) {
    return 'Too many failed attempts. Try again in $seconds seconds.';
  }

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorWrongCurrentPassword => 'Current password is incorrect.';

  @override
  String get navLibrary => 'Library';

  @override
  String get navReadingStatus => 'Reading';

  @override
  String get navGoal => 'Goal';

  @override
  String get navLoans => 'Loans';

  @override
  String navLoansOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue returns',
      one: '1 overdue return',
    );
    return 'Loans: $_temp0';
  }

  @override
  String get loansTitle => 'Loan Tracker';

  @override
  String get libraryTitle => 'My Library';

  @override
  String get readingStatusTitle => 'Reading Status';

  @override
  String get readingGoalTitle => 'Yearly Reading Goal';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNotificationsTitle => 'Notifications';

  @override
  String get settingsLoanReminders => 'Return reminders';

  @override
  String get settingsLoanRemindersHint =>
      'Sends a notification at 10:00 the day before and on the day a lent book is due back.';

  @override
  String get settingsLoanRemindersDenied =>
      'Notifications are turned off. To see reminders, allow Kitalog notifications in your phone settings.';

  @override
  String get settingsReadingReminders => 'Daily reading reminder';

  @override
  String get settingsReadingRemindersHint =>
      'Invites you to read every day at the time you choose; skipped on days you have already read. Reminds you of your streak when you read several days in a row.';

  @override
  String get settingsStalledReminders => 'Unfinished books';

  @override
  String settingsStalledRemindersHint(int days) {
    return 'Reminds you once, at the time you choose, when a book you are reading has had no progress for $days days.';
  }

  @override
  String get settingsReadingReminderTime => 'Reading reminder time';

  @override
  String get libraryFilters => 'Filters';

  @override
  String libraryFiltersActive(int count) {
    return 'Filters ($count selected)';
  }

  @override
  String get libraryFilterFormat => 'Format';

  @override
  String get libraryFilterGenre => 'Genre';

  @override
  String get libraryFilterClear => 'Clear';

  @override
  String get libraryFilterRemove => 'Remove filter';

  @override
  String libraryShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count books',
      one: 'Show 1 book',
      zero: 'No matching books',
    );
    return '$_temp0';
  }

  @override
  String get librarySearchHint => 'Search title or author';

  @override
  String get libraryAddBook => 'Add book';

  @override
  String get libraryEmptyTitle => 'Your library is empty';

  @override
  String get libraryEmptyMessage => 'Tap “Add book” to add your first book.';

  @override
  String get libraryNoResultsTitle => 'No results';

  @override
  String get libraryNoResultsMessage => 'Try changing the search or filters.';

  @override
  String get physicalBadge => 'Physical';

  @override
  String get digitalBadge => 'Digital';

  @override
  String get loanedBadge => 'On loan';

  @override
  String get bookDetailTitle => 'Book Details';

  @override
  String get bookNotFound => 'Book not found.';

  @override
  String get authorUnknown => 'Unknown author';

  @override
  String bookPageCount(int count) {
    return '$count pages';
  }

  @override
  String bookIsbn(String isbn) {
    return 'ISBN: $isbn';
  }

  @override
  String get bookOwned => 'I have a physical copy';

  @override
  String get bookNotOwned => 'No physical copy';

  @override
  String get pageCounterTitle => 'Reading Progress';

  @override
  String get pageEditTooltip => 'Enter page number';

  @override
  String get pageEditTitle => 'Current page';

  @override
  String pageEditLabel(int max) {
    return 'Page (0 - $max)';
  }

  @override
  String get pageDecrement => 'Back 1 page';

  @override
  String get pageIncrement => 'Forward 1 page';

  @override
  String pageDecrementBig(int count) {
    return 'Back $count pages';
  }

  @override
  String pageIncrementBig(int count) {
    return 'Forward $count pages';
  }

  @override
  String get finishReachedMessage =>
      'You reached the last page. The book will be marked as \"Finished\" and count toward this year\'s reading goal.';

  @override
  String get markFinished => 'Mark as finished';

  @override
  String get statusSectionTitle => 'Reading Status';

  @override
  String startedAtLabel(String date) {
    return 'Started: $date';
  }

  @override
  String finishedAtLabel(String date) {
    return 'Finished: $date';
  }

  @override
  String get ratingSectionTitle => 'Rating & Review';

  @override
  String get reviewEdit => 'Edit review';

  @override
  String get reviewDialogTitle => 'Personal Review';

  @override
  String get reviewHint => 'Write your review';

  @override
  String get reviewEmpty => 'You have not written a review yet.';

  @override
  String get quotesSectionTitle => 'Quotes';

  @override
  String get quotesEmpty => 'No quotes added yet.';

  @override
  String get quoteAdd => 'Add quote';

  @override
  String get quoteText => 'Quote text';

  @override
  String get quotePage => 'Page number (optional)';

  @override
  String quotePageLabel(int page) {
    return 'p. $page';
  }

  @override
  String get quoteFavorite => 'Add to favorites';

  @override
  String get quoteUnfavorite => 'Remove from favorites';

  @override
  String get quoteDelete => 'Delete quote';

  @override
  String get notesSectionTitle => 'Notes';

  @override
  String get notesEmpty => 'No notes added yet.';

  @override
  String get noteAdd => 'Add note';

  @override
  String get noteContent => 'Note';

  @override
  String get noteDelete => 'Delete note';

  @override
  String get loanSectionTitle => 'Loan Info';

  @override
  String get loanNone => 'This book is not on loan.';

  @override
  String get loanLend => 'Lend book';

  @override
  String get loanBorrower => 'Lent to whom?';

  @override
  String get loanDueDate => 'Pick a return date (optional)';

  @override
  String get loanClearDate => 'Clear date';

  @override
  String loanLentTo(String name) {
    return 'Lent to $name';
  }

  @override
  String loanLentAt(String date) {
    return 'Lent on: $date';
  }

  @override
  String loanDueAt(String date) {
    return 'Return by: $date';
  }

  @override
  String get loanOverdue => 'Overdue';

  @override
  String get loanReturn => 'Mark as returned';

  @override
  String get loansTabActive => 'On loan';

  @override
  String get loansTabHistory => 'History';

  @override
  String get loansSummaryActive => 'On loan';

  @override
  String get loansSummaryOverdue => 'Overdue';

  @override
  String get loansSummaryDueSoon => 'Due soon';

  @override
  String loansDaysOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'on loan for $count days',
      one: 'on loan for 1 day',
      zero: 'lent today',
    );
    return '$_temp0';
  }

  @override
  String get loansDueNone => 'No return date';

  @override
  String get loansDueToday => 'Due back today';

  @override
  String loansDueIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due back in $count days',
      one: 'Due back tomorrow',
    );
    return '$_temp0';
  }

  @override
  String loansOverdueBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String get loansEdit => 'Edit';

  @override
  String get loansEditTitle => 'Edit Loan Info';

  @override
  String get loansReturnConfirmTitle => 'Mark as returned?';

  @override
  String loansReturnConfirmMessage(String title, String name) {
    return '“$title” will be marked as returned by $name and added to your loan history.';
  }

  @override
  String get loansPickBookTitle => 'Choose a book to lend';

  @override
  String get loansNoLendableTitle => 'No books to lend';

  @override
  String get loansNoLendableMessage =>
      'Books you own a physical copy of and that are not on loan are listed here.';

  @override
  String get loansEmptyActiveTitle => 'No books on loan';

  @override
  String get loansEmptyActiveMessage =>
      'When you lend one of your physical books, you can track who has it and when it is due back here.';

  @override
  String get loansEmptyHistoryTitle => 'Loan history is empty';

  @override
  String get loansEmptyHistoryMessage => 'Books you get back are listed here.';

  @override
  String loansHistoryPeriod(String lent, String returned) {
    return '$lent – $returned';
  }

  @override
  String loansHistoryDuration(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'same day',
    );
    return '$_temp0';
  }

  @override
  String get loansReturnedLate => 'Returned late';

  @override
  String get loanReminderChannelName => 'Loan reminders';

  @override
  String get loanReminderChannelDescription =>
      'Reminds you when books you lent are due back.';

  @override
  String get loanReminderTomorrowTitle => 'Due back tomorrow';

  @override
  String get loanReminderTodayTitle => 'Due back today';

  @override
  String loanReminderBody(String title, String name) {
    return '$name should return “$title”.';
  }

  @override
  String get readingReminderChannelName => 'Reading reminders';

  @override
  String get readingReminderChannelDescription =>
      'Invites you to read every day at the time you choose and reminds you of unfinished books.';

  @override
  String get readingReminderTitle => 'Time to read';

  @override
  String readingReminderBody(String title, int page) {
    return 'You\'re on page $page of “$title”. How about 10 minutes of reading?';
  }

  @override
  String readingReminderBodyStart(String title) {
    return '“$title” is waiting for you. How about 10 minutes of reading?';
  }

  @override
  String get readingReminderBodyNoBook =>
      'How about reading a few pages today? There are books waiting in your library.';

  @override
  String readingReminderStreakTitle(int days) {
    return '$days-day reading streak, keep it going!';
  }

  @override
  String get readingReminderStalledTitle => 'Unfinished book';

  @override
  String readingReminderStalledBody(String title, int days) {
    return 'No progress on “$title” for $days days. How about picking up where you left off?';
  }

  @override
  String get deleteBook => 'Delete book';

  @override
  String get deleteBookTitle => 'Delete this book?';

  @override
  String deleteBookMessage(String title) {
    return '“$title” and its quotes and notes will be permanently deleted.';
  }

  @override
  String readingTabLabel(String status, int count) {
    return '$status ($count)';
  }

  @override
  String get readingEmptyReadingTitle => 'You are not reading anything';

  @override
  String get readingEmptyReadingMessage =>
      'Pick a book from your to-read list and start reading.';

  @override
  String get readingEmptyToReadTitle => 'Your to-read list is empty';

  @override
  String get readingEmptyToReadMessage =>
      'Mark a book in your library as “To read”.';

  @override
  String get readingEmptyFinishedTitle => 'No finished books yet';

  @override
  String get readingEmptyFinishedMessage =>
      'Books you finish will appear here.';

  @override
  String get startReading => 'Start reading';

  @override
  String get errorPageCountInvalid =>
      'Page count must be a number of 1 or more.';

  @override
  String get errorUrlInvalid => 'Enter a valid http/https address.';

  @override
  String get errorIsbnInvalid => 'Enter a valid ISBN (10 or 13 digits).';

  @override
  String get addBookTitle => 'Add New Book';

  @override
  String get addBookModeSearch => 'ISBN / Search';

  @override
  String get addBookModeManual => 'Manual';

  @override
  String get addBookSearchLabel => 'ISBN, title or author';

  @override
  String get addBookSearchHint => 'e.g. 9780375508325 or Cosmos';

  @override
  String get addBookSearchButton => 'Search';

  @override
  String get addBookSearchEmptyTitle => 'Search books on Open Library';

  @override
  String get addBookSearchEmptyMessage =>
      'Enter an ISBN or a title/author. If nothing is found you can add it manually.';

  @override
  String get addBookErrorEmptyQuery =>
      'Enter an ISBN, title or author to search.';

  @override
  String get addBookErrorInvalidIsbn =>
      'This ISBN is not valid. Check the digits.';

  @override
  String get addBookErrorNotFound =>
      'No results. You can add the book manually.';

  @override
  String get addBookErrorNetwork => 'Could not connect to the internet.';

  @override
  String get addBookErrorServer => 'Open Library is not responding right now.';

  @override
  String get addBookErrorDuplicate => 'A book with this ISBN already exists.';

  @override
  String get addBookGoManual => 'Add manually';

  @override
  String get addBookSave => 'Add to library';

  @override
  String get addBookSaved => 'Book added to your library.';

  @override
  String get fieldBookTitle => 'Title';

  @override
  String get fieldBookAuthors => 'Author(s)';

  @override
  String get fieldBookAuthorsHelper => 'Separate multiple authors with commas.';

  @override
  String get fieldBookPages => 'Page count';

  @override
  String get genreAdd => 'Add new category';

  @override
  String get genreNewTitle => 'New category';

  @override
  String get genreNewName => 'Category name';

  @override
  String get genreNewColor => 'Color';

  @override
  String genreColorOption(int number) {
    return 'Color $number';
  }

  @override
  String get genreNewSave => 'Add';

  @override
  String get errorGenreNameTooLong =>
      'Category name can be at most 30 characters.';

  @override
  String get errorGenreNameTaken =>
      'This category already exists; pick it from the list.';

  @override
  String get fieldBookGenre => 'Genre';

  @override
  String get fieldBookStatus => 'Reading status';

  @override
  String get fieldBookIsbn => 'ISBN (optional)';

  @override
  String get fieldBookCover => 'Cover';

  @override
  String get coverFromGallery => 'Choose from gallery';

  @override
  String get coverFromCamera => 'Take photo';

  @override
  String get coverRemove => 'Remove image';

  @override
  String get coverFromDeviceSelected =>
      'The image from your device will be used as the cover.';

  @override
  String get coverPickFailed => 'Couldn\'t pick the image. Please try again.';

  @override
  String get fieldBookCoverUrl => 'Cover URL (optional)';

  @override
  String get fieldBookOwned => 'I have a physical copy of this book';

  @override
  String goalYearLabel(int year) {
    return '$year Reading Goal';
  }

  @override
  String goalProgress(int finished, int target) {
    return '$finished / $target books';
  }

  @override
  String goalRemaining(int count) {
    return '$count books to go';
  }

  @override
  String get goalCompleted => 'You reached your yearly goal, congratulations!';

  @override
  String goalTarget(int target) {
    return 'Goal: $target books';
  }

  @override
  String get goalDecrease => 'Decrease goal';

  @override
  String get goalIncrease => 'Increase goal';

  @override
  String get goalTotalPages => 'Total pages read';

  @override
  String get goalMonthlyTitle => 'Books finished per month';

  @override
  String goalMonthSemantics(String month, int count) {
    return '$month: $count books';
  }

  @override
  String get goalGenreTitle => 'Breakdown by genre';

  @override
  String get goalGenreEmpty => 'No finished books this year yet.';

  @override
  String get profileAvatar => 'Profile picture';

  @override
  String get profileChangeAvatar => 'Change profile picture';

  @override
  String profileMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get avatarPresetTitle => 'Choose a preset avatar';

  @override
  String get avatarFromGallery => 'Upload from gallery';

  @override
  String get avatarFromCamera => 'Take a photo';

  @override
  String get avatarRemove => 'Remove profile picture';

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsUpdateEmail => 'Update email address';

  @override
  String get settingsUpdatePhone => 'Update phone number';

  @override
  String get settingsUpdatePassword => 'Update password';

  @override
  String get fieldCurrentPassword => 'Current password';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get settingsEmailSaved => 'Email updated.';

  @override
  String get settingsPhoneSaved => 'Phone updated.';

  @override
  String get settingsPasswordSaved => 'Password updated.';

  @override
  String get settingsAvatarSaved => 'Profile picture updated.';

  @override
  String get settingsAvatarFailed =>
      'Could not pick the image. Please try again.';

  @override
  String get settingsLogout => 'Sign out';

  @override
  String get settingsLogoutTitle => 'Sign out?';

  @override
  String get settingsLogoutMessage =>
      'Your data is kept; you can sign in again.';

  @override
  String get readerDownloadTitle => 'This book is not on your device yet';

  @override
  String get readerDownloadMessage =>
      'Download it once and read it even without internet.';

  @override
  String get readerDownloadWebNote =>
      'On the web the text is kept only for this session; use the mobile app for offline reading.';

  @override
  String get readerDownloadButton => 'Download and read';

  @override
  String readerDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String get readerErrorNetwork =>
      'Could not connect. A connection is needed to download.';

  @override
  String get readerErrorServer =>
      'The source is not responding. Try again shortly.';

  @override
  String get readerErrorNotFound =>
      'This book\'s text was not found at its source.';

  @override
  String get readerErrorStorage =>
      'The text could not be saved. Check your storage.';

  @override
  String get readerErrorUnavailable => 'This book has no free digital edition.';

  @override
  String readerPageIndicator(int current, int total) {
    return '$current / $total';
  }

  @override
  String get readerPrevious => 'Previous page';

  @override
  String get readerNext => 'Next page';

  @override
  String get readerQuoteSave => 'Save as quote';

  @override
  String get readerQuoteSaved => 'Quote saved to the book\'s Quotes section.';

  @override
  String get readerQuoteDuplicate => 'This quote is already saved.';

  @override
  String get readerTranslate => 'Translation';

  @override
  String get readerTranslateSelection => 'Translate';

  @override
  String get readerTranslationOriginal => 'Original';

  @override
  String get readerTranslationTurkish => 'Turkish translation';

  @override
  String get readerTranslationEnglish => 'English translation';

  @override
  String get readerTranslationBoth => 'Original with translation';

  @override
  String get readerTranslationTranslating => 'Translating page…';

  @override
  String get readerTranslationDownloading =>
      'Downloading translation language pack…';

  @override
  String get readerTranslationModelTitle =>
      'Download the translation language pack?';

  @override
  String get readerTranslationModelMessage =>
      'Translation runs on your device. The English and Turkish language packs need to be downloaded once (about 30 MB). After that, translation works offline too.';

  @override
  String get readerTranslationModelDownload => 'Download';

  @override
  String get readerTranslationErrorModel =>
      'The language pack couldn\'t be downloaded. Check your internet connection and try again.';

  @override
  String get readerTranslationErrorTranslate =>
      'The text couldn\'t be translated.';

  @override
  String get readerTranslationNote =>
      'On-device machine translation; it may contain mistakes.';

  @override
  String get readerTranslationCopy => 'Copy';

  @override
  String get readerTranslationCopied => 'Translation copied.';

  @override
  String get readerTextSize => 'Text size';

  @override
  String readerTextScaleValue(int percent) {
    return '$percent%';
  }

  @override
  String get digitalSectionTitle => 'Digital Edition';

  @override
  String get digitalDownload => 'Download for offline reading';

  @override
  String get digitalRead => 'Read';

  @override
  String get digitalDelete => 'Remove from device';

  @override
  String get fileErrorUnsupported => 'Only PDF and EPUB files are supported.';

  @override
  String get fileErrorInvalid =>
      'The file could not be opened; it may be a damaged or invalid PDF/EPUB.';

  @override
  String get fileErrorProtected =>
      'This file is copy-protected (DRM); protected books cannot be opened.';

  @override
  String get fileErrorTooLarge => 'The file is too large (maximum 150 MB).';

  @override
  String get fileErrorMissing =>
      'The file was not found on this device. You can upload it again from the book details.';

  @override
  String get digitalImportHint =>
      'Upload your own PDF or EPUB file to read it in the app. The file is stored only on this device.';

  @override
  String get digitalImportButton => 'Upload file (PDF / EPUB)';

  @override
  String get digitalImporting => 'Preparing the file…';

  @override
  String get digitalReplaceFile => 'Upload another file';

  @override
  String statusCurrentLabel(String status) {
    return 'Status: $status';
  }

  @override
  String get readAgain => 'Read again';

  @override
  String get finishConfirmTitle => 'Did you finish this book?';

  @override
  String get finishConfirmMessage =>
      'The book will be marked as finished and your progress will move to the last page.';

  @override
  String get readAgainConfirmTitle => 'Read this book again?';

  @override
  String get readAgainConfirmMessage =>
      'Your progress will be reset and the book will move to \"Reading\". It won\'t count toward your yearly goal until you finish it again.';
}
