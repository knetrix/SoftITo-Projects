// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get scrWelcome => 'Welcome';

  @override
  String get scrSignin => 'Sign in';

  @override
  String get scrSignup => 'Create account';

  @override
  String get scrTeam => 'Build Team';

  @override
  String get scrAppointments => 'My Bookings';

  @override
  String get scrAppointmentDetail => 'Booking detail';

  @override
  String get scrProfile => 'Profile';

  @override
  String get scrSocial => 'Chat and Friends';

  @override
  String get scrChat => 'Conversation';

  @override
  String get scrNotifications => 'Notifications';

  @override
  String signedIn(String name) {
    return 'Signed in as $name';
  }

  @override
  String get signedOut => 'Signed out';

  @override
  String get eName => 'Enter at least 2 characters.';

  @override
  String get eEmail => 'Enter a valid email address.';

  @override
  String get ePassword => 'Enter your password.';

  @override
  String get ePwlen => 'Use at least 8 characters.';

  @override
  String get eNoacct => 'No account uses that email.';

  @override
  String get eWrongpw => 'That password is not right. Try again or reset it.';

  @override
  String get eExists => 'That email already has an account. Sign in instead.';

  @override
  String get ePhoneExists =>
      'That phone number already has an account. Sign in instead.';

  @override
  String get undo => 'Undo';

  @override
  String get cancel => 'Cancel';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get onbH => 'Line up your seven-a-side squad.';

  @override
  String get onbP =>
      'Pick a formation, hand out the bibs, set the pitch and the hour.';

  @override
  String get onbF1 => '5 formations, goalkeeper always fixed';

  @override
  String get onbF2 => 'Sample pitches and hours in all 81 provinces';

  @override
  String get onbF3 => 'Chat with your teammates';

  @override
  String get onbStart => 'Get started';

  @override
  String get onbHave => 'I have an account, sign in';

  @override
  String get imgWelcome =>
      'Mesh bibs piled on the turf, the orange goalkeeper bib on top, a ball beside them';

  @override
  String get imgSignin => 'Folded green and orange bibs next to training cones';

  @override
  String get imgPitch => 'Sample picture of the pitch';

  @override
  String get imgEmptyAppts =>
      'A ball waiting in front of a goal on an empty pitch';

  @override
  String get imgEmptyChats =>
      'Water bottles and a folded orange bib on a pitch-side bench';

  @override
  String get onbArt => 'Seven numbered bibs lined up in a 2-3-1 formation';

  @override
  String get siH => 'Sign in';

  @override
  String get siP => 'Pick up your squad where you left it.';

  @override
  String get fPw => 'Password';

  @override
  String get showPw => 'Show password';

  @override
  String get hidePw => 'Hide password';

  @override
  String get forgot => 'Forgot password';

  @override
  String get siBtn => 'Sign in';

  @override
  String get siBusy => 'Signing in…';

  @override
  String get noAcct => 'Don\'t have an account?';

  @override
  String get toSignup => 'Create account';

  @override
  String get fpH => 'Reset your password';

  @override
  String get fpP =>
      'Enter your account email and we will send you a password reset link.';

  @override
  String get fEmail => 'Email';

  @override
  String get fNewpw => 'New password';

  @override
  String get fpBtn => 'Send link';

  @override
  String get fpBusy => 'Sending…';

  @override
  String get suH => 'Create your account';

  @override
  String get suP => 'A few details and you can build your squad.';

  @override
  String get fFirst => 'First name';

  @override
  String get fLast => 'Last name';

  @override
  String get fPhone => 'Phone number';

  @override
  String get pwHint => 'At least 8 characters';

  @override
  String get suBtn => 'Create account';

  @override
  String get suBusy => 'Creating account…';

  @override
  String get agreeTermsA => 'User Agreement';

  @override
  String get agreeKvkkA => 'KVKK privacy notice';

  @override
  String get agreeSuffix => 'read and understood.';

  @override
  String get chkTerms => 'I have read and understood the User Agreement';

  @override
  String get chkKvkk => 'I have read and understood the KVKK notice';

  @override
  String get eFirst => 'Enter your first name.';

  @override
  String get eLast => 'Enter your last name.';

  @override
  String get ePhone => 'Enter your phone number as 05XX XXX XX XX.';

  @override
  String get eTerms => 'Accept the agreement to continue.';

  @override
  String get eKvkk => 'Accept the KVKK notice to continue.';

  @override
  String get hasAcct => 'Already have an account?';

  @override
  String get toSignin => 'Sign in';

  @override
  String get accountCreated => 'Account created. Now sign in.';

  @override
  String get legalNote =>
      'Sample text. A legal expert will write the final version before launch.';

  @override
  String get termsP1 =>
      '7v7 helps you set up carpet-pitch teams and matches. This version is a prototype.';

  @override
  String get termsP2 =>
      'Pitch names in the app are samples. This version makes no real booking or payment.';

  @override
  String get termsP3 =>
      'You agree to treat other users with respect and not to post abusive content in chats.';

  @override
  String get kvkkP1 =>
      'Your name, email and phone are used to create your account.';

  @override
  String get kvkkP2 =>
      'In this prototype your details are stored in Firebase only to run the app.';

  @override
  String get kvkkP3 => 'You can ask for your data to be deleted at any time.';

  @override
  String get legalOk => 'I have read it and accept';

  @override
  String get tabTeam => 'Build Team';

  @override
  String get tabAppts => 'Bookings';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabSocial => 'Chat';

  @override
  String get notifBtn => 'Notifications';

  @override
  String notifUnread(String n) {
    return '$n unread';
  }

  @override
  String get back => 'Back';

  @override
  String get locCity => 'Province';

  @override
  String get locDistrict => 'District';

  @override
  String get locStadium => 'Pitch';

  @override
  String get pick => 'Choose';

  @override
  String get required => 'Required';

  @override
  String get matchTime => 'Kick-off';

  @override
  String get oneHour => '1 hour';

  @override
  String get squad => 'Squad';

  @override
  String squadN(String n) {
    return '$n/7 players';
  }

  @override
  String formationBtn(String f) {
    return 'Formation $f';
  }

  @override
  String get formationNone => 'Choose formation';

  @override
  String get saveTeam => 'Save team';

  @override
  String get pickFormationFirst => 'Choose a formation to line up your squad.';

  @override
  String get missing => 'Missing:';

  @override
  String get mFormation => 'formation';

  @override
  String mPlayers(String n) {
    return '$n players';
  }

  @override
  String get mCity => 'province';

  @override
  String get mDistrict => 'district';

  @override
  String get mStadium => 'pitch';

  @override
  String get mTime => 'kick-off';

  @override
  String get posGk => 'Goalkeeper';

  @override
  String get posDef => 'Defender';

  @override
  String get posMid => 'Midfield';

  @override
  String get posAtt => 'Forward';

  @override
  String addPlayerTo(String pos) {
    return 'Add a player at $pos';
  }

  @override
  String editPlayer(String name, String pos) {
    return '$name, $pos. Edit';
  }

  @override
  String get fpTitle => 'Choose formation';

  @override
  String get fpSub =>
      'The goalkeeper is fixed in every formation. 7 players in total.';

  @override
  String fdD(String n) {
    return 'Defence $n';
  }

  @override
  String fdM(String n) {
    return 'Midfield $n';
  }

  @override
  String fdA(String n) {
    return 'Attack $n';
  }

  @override
  String movedOne(String name, String pos) {
    return '$name moved to $pos in the new formation';
  }

  @override
  String movedMany(String names) {
    return 'Moved in the new formation: $names';
  }

  @override
  String formationSet(String f) {
    return 'Formation set to $f';
  }

  @override
  String get fLastOpt => 'Last name (optional)';

  @override
  String get ppSave => 'Save player';

  @override
  String get ppRemove => 'Remove player';

  @override
  String get ePfirst => 'Enter the player\'s first name.';

  @override
  String eDup(String name, String pos) {
    return '$name is already at $pos. One person cannot fill two positions, enter a different player.';
  }

  @override
  String playerSaved(String name, String pos) {
    return '$name added at $pos';
  }

  @override
  String playerUpdated(String name) {
    return '$name updated';
  }

  @override
  String playerRemoved(String name) {
    return '$name removed from the squad';
  }

  @override
  String get cpTitle => 'Choose province';

  @override
  String get cpSearch => 'Search provinces';

  @override
  String get cpSub => 'All 81 provinces of Türkiye';

  @override
  String noCity(String q) {
    return 'No province matches \"$q\".';
  }

  @override
  String get cityChanged =>
      'Province changed. Choose the district and pitch again.';

  @override
  String get dpTitle => 'Choose district';

  @override
  String get dpNeed => 'Choose a province first to see its districts.';

  @override
  String get dpSample => 'Sample district list';

  @override
  String get spTitle => 'Choose a pitch';

  @override
  String get spNeed => 'Choose a district first to see pitches.';

  @override
  String get spSample => 'Sample pitch names. No real booking is made.';

  @override
  String get tpTitle => 'Choose kick-off';

  @override
  String get tpSub => 'Every match lasts 1 hour.';

  @override
  String get savedAppt => 'Booking saved';

  @override
  String get apH => 'My Bookings';

  @override
  String get sampleTag => 'Sample';

  @override
  String get guestTag => 'Guest';

  @override
  String get buildingTag => 'Squad in progress';

  @override
  String get organizer => 'Organiser';

  @override
  String nSaved(String name, String time) {
    return '$name saved the match, $time';
  }

  @override
  String get newMatch => 'Set up a new match';

  @override
  String get apSearch => 'Search pitch, district or player';

  @override
  String get fAll => 'All';

  @override
  String get fDay => 'Daytime';

  @override
  String get fEve => 'Evening';

  @override
  String nAppts(String n) {
    return '$n bookings';
  }

  @override
  String playersN(String n) {
    return '$n players';
  }

  @override
  String get apEmptyT => 'No bookings yet';

  @override
  String get apEmptyD =>
      'On Build Team, choose the squad, pitch and hour, then save with the green tick.';

  @override
  String get apEmptyBtn => 'Build a team';

  @override
  String get apNone => 'No bookings match this search.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get detTime => 'Time';

  @override
  String get detDur => 'Length';

  @override
  String get detForm => 'Formation';

  @override
  String get reuseBtn => 'Copy squad to Build Team';

  @override
  String get delAppt => 'Delete booking';

  @override
  String deletedAppt(String name) {
    return '$name booking deleted';
  }

  @override
  String get reused => 'Squad copied to Build Team';

  @override
  String get detNoneT => 'No booking selected';

  @override
  String get detNoneD => 'Open a booking from My Bookings.';

  @override
  String get detNoneBtn => 'Go to My Bookings';

  @override
  String get soFriends => 'Add Friends';

  @override
  String get soChats => 'Chats';

  @override
  String get userSearch => 'Search names';

  @override
  String get reqSend => 'Send request';

  @override
  String get reqSentBtn => 'Request sent';

  @override
  String reqSent(String name) {
    return 'Request sent to $name';
  }

  @override
  String get friendsYes => 'You are friends';

  @override
  String msgUser(String name) {
    return 'Message $name';
  }

  @override
  String noUsers(String q) {
    return 'No sample user named \"$q\".';
  }

  @override
  String get chatsEmptyT => 'No chats yet';

  @override
  String get chatsEmptyD => 'Start by messaging someone from Add Friends.';

  @override
  String get chatsEmptyBtn => 'Find friends';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get you => 'You:';

  @override
  String get chatNote => 'Sample chat. Only the two of you see these messages.';

  @override
  String get msgPh => 'Write a message';

  @override
  String get send => 'Send';

  @override
  String get msgBtn => 'Message';

  @override
  String get eMsg => 'Write a message first.';

  @override
  String get chatFirst =>
      'Write the first message. You can share the kick-off or the pitch.';

  @override
  String get chatNoneT => 'No chat selected';

  @override
  String get chatNoneD => 'Open one from your chat list.';

  @override
  String get chatNoneBtn => 'Back to chats';

  @override
  String get noH => 'Notifications';

  @override
  String get markAll => 'Mark all as read';

  @override
  String get sampleNotifs => 'Sample notifications';

  @override
  String get newTag => 'New';

  @override
  String nRequest(String name) {
    return '$name sent you a friend request';
  }

  @override
  String nAccepted(String name) {
    return '$name accepted your friend request';
  }

  @override
  String nReminder(String time) {
    return 'Match reminder, $time';
  }

  @override
  String nMessage(String name) {
    return '$name sent a new message';
  }

  @override
  String get noEmptyT => 'No notifications';

  @override
  String get noEmptyD =>
      'Friend requests, match reminders and messages show up here.';

  @override
  String get apptGone => 'This booking was deleted';

  @override
  String get allRead => 'All notifications marked as read';

  @override
  String agoM(String n) {
    return '$n min ago';
  }

  @override
  String agoH(String n) {
    return '$n h ago';
  }

  @override
  String agoD(String n) {
    return '$n d ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get scrInvite => 'Match invite';

  @override
  String invTitle(String name) {
    return 'Invite $name to your match';
  }

  @override
  String get invNeedMatch =>
      'To send an invite, first choose the formation, province, district, pitch and hour on Build Team.';

  @override
  String get invFull =>
      'Your squad has no open position to offer. Free one up on Build Team.';

  @override
  String get goTeam => 'Go to Build Team';

  @override
  String get invOfferPick => 'Position to offer';

  @override
  String get invSend => 'Send invite';

  @override
  String invSent(String name, String pos) {
    return 'Invite sent to $name with the $pos spot';
  }

  @override
  String invWithdrawn(String name) {
    return 'Invite to $name withdrawn';
  }

  @override
  String get invFriend => 'Invite to match';

  @override
  String get invSentBtn => 'Invite sent';

  @override
  String get invTo => 'you invited';

  @override
  String invSenderPending(String name) {
    return 'Waiting for $name';
  }

  @override
  String invSenderAccepted(String name, String pos) {
    return '$name accepted and is at $pos';
  }

  @override
  String invSenderRejected(String name) {
    return '$name declined';
  }

  @override
  String invOffered(String pos) {
    return '$pos offered';
  }

  @override
  String get invRefused => 'Declined your invite';

  @override
  String get invView => 'View invite';

  @override
  String waiting(String name) {
    return '$name pending';
  }

  @override
  String slotWaiting(String name, String pos) {
    return '$pos, waiting for $name';
  }

  @override
  String nWaiting(String n) {
    return '$n invite pending';
  }

  @override
  String waitText(String name) {
    return '$name was invited to this position. Waiting for an answer.';
  }

  @override
  String get withdraw => 'Withdraw invite';

  @override
  String get inInvites => 'Invites for you';

  @override
  String inInvLine(String pos) {
    return 'Offers you $pos';
  }

  @override
  String get invH => 'Match invite';

  @override
  String get invFrom => 'invites you to a match';

  @override
  String get invOfferLabel => 'Position offered to you';

  @override
  String get invOfferDone => 'Your name is on this position';

  @override
  String get offerYou => 'Your spot';

  @override
  String get emptySlot => 'Open';

  @override
  String get offerRow => 'Open, offered to you';

  @override
  String get invAccept => 'Accept';

  @override
  String get invReject => 'Decline';

  @override
  String invChat(String name) {
    return 'Chat with $name';
  }

  @override
  String invAcceptedT(String pos) {
    return 'Invite accepted. Your name is now at $pos.';
  }

  @override
  String invRejectedT(String name) {
    return 'Invite declined. $name was notified.';
  }

  @override
  String invStatusAcc(String name) {
    return 'You accepted. You and $name are now friends.';
  }

  @override
  String invStatusRej(String name) {
    return 'You declined. $name was notified.';
  }

  @override
  String get invRejQ => 'Decline this invite?';

  @override
  String get invRejD =>
      'The sender will be notified and the position opens up again in their squad.';

  @override
  String get invRejYes => 'Yes, decline';

  @override
  String get invNoneT => 'No invite selected';

  @override
  String get invNoneD => 'Open an invite from Notifications or Add Friends.';

  @override
  String nInvite(String name) {
    return '$name invited you to a match';
  }

  @override
  String nInviteSub(String place, String pos) {
    return 'Offers $pos, $place';
  }

  @override
  String nInvAcc(String name) {
    return '$name accepted your invite';
  }

  @override
  String nInvAccSub(String pos) {
    return 'Added at $pos';
  }

  @override
  String nInvRej(String name) {
    return '$name declined your invite';
  }

  @override
  String nInvRejSub(String pos) {
    return '$pos is open again';
  }

  @override
  String get inviteGone => 'This invite is gone';

  @override
  String get prH => 'Profile';

  @override
  String get prPhone => 'Phone';

  @override
  String get prEmail => 'Email address';

  @override
  String get prAppts => 'Bookings';

  @override
  String get prFriends => 'Friends';

  @override
  String get prLook => 'Appearance';

  @override
  String get prAccount => 'Account';

  @override
  String get signOut => 'Sign out';

  @override
  String get noPhone => 'No phone added';

  @override
  String get fpSent => 'A password reset link was sent to your email.';

  @override
  String get eGeneric => 'Something went wrong. Try again.';

  @override
  String get langTr => 'Türkçe';

  @override
  String get langEn => 'English';

  @override
  String get delAcct => 'Delete account';

  @override
  String get delH => 'Delete your account';

  @override
  String get delP =>
      'Your profile, contact details, appointments, invites, friendships and messages will be permanently deleted. This can\'t be undone. Enter your password to confirm.';

  @override
  String get delBtn => 'Delete permanently';

  @override
  String get delBusy => 'Deleting…';

  @override
  String get accountDeleted => 'Your account was deleted.';
}
