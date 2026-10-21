// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get libraryTitle => 'My Library';

  @override
  String get readingStatusTitle => 'Reading Status';

  @override
  String get readingGoalTitle => 'Yearly Reading Goal';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get libraryFilterAll => 'All';

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
  String get bookOwned => 'In my collection';

  @override
  String get bookNotOwned => 'Not in my collection';

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
  String get finishSuggestion =>
      'You reached the last page. Did you finish the book?';

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
  String get fieldBookGenre => 'Genre';

  @override
  String get fieldBookStatus => 'Reading status';

  @override
  String get fieldBookIsbn => 'ISBN (optional)';

  @override
  String get fieldBookCoverUrl => 'Cover URL (optional)';

  @override
  String get fieldBookOwned => 'I own this book';

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
}
