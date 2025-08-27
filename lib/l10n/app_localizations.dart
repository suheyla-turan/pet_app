import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PatiTakip'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support / Feedback'**
  String get support;

  /// No description provided for @infoSupport.
  ///
  /// In en, this message translates to:
  /// **'Info & Support'**
  String get infoSupport;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @advancedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Advanced Notifications'**
  String get advancedNotifications;

  /// No description provided for @updateInterval.
  ///
  /// In en, this message translates to:
  /// **'Update Interval'**
  String get updateInterval;

  /// No description provided for @updateIntervalDescription.
  ///
  /// In en, this message translates to:
  /// **'Select how often pet statuses are updated'**
  String get updateIntervalDescription;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @aiAskTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask AI a Question'**
  String get aiAskTitle;

  /// No description provided for @recognizedText.
  ///
  /// In en, this message translates to:
  /// **'Recognized Text'**
  String get recognizedText;

  /// No description provided for @askHint.
  ///
  /// In en, this message translates to:
  /// **'Type or ask your question...'**
  String get askHint;

  /// No description provided for @voiceAsk.
  ///
  /// In en, this message translates to:
  /// **'Voice Ask'**
  String get voiceAsk;

  /// No description provided for @stopListening.
  ///
  /// In en, this message translates to:
  /// **'Stop Listening'**
  String get stopListening;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @ask.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get ask;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @userEmailHint.
  ///
  /// In en, this message translates to:
  /// **'User email address'**
  String get userEmailHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @petIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pet ID not found!'**
  String get petIdNotFound;

  /// No description provided for @userAdded.
  ///
  /// In en, this message translates to:
  /// **'User added!'**
  String get userAdded;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found!'**
  String get userNotFound;

  /// No description provided for @mainUserCannotRemoveSelf.
  ///
  /// In en, this message translates to:
  /// **'Main user cannot remove self!'**
  String get mainUserCannotRemoveSelf;

  /// No description provided for @onlyMainUserCanRemove.
  ///
  /// In en, this message translates to:
  /// **'Only main user can remove others!'**
  String get onlyMainUserCanRemove;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your app preferences'**
  String get settingsDescription;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeSystem;

  /// No description provided for @themeLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLightDesc;

  /// No description provided for @themeDarkDesc.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDarkDesc;

  /// No description provided for @themeSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Use device theme'**
  String get themeSystemDesc;

  /// No description provided for @aiConversationStyle.
  ///
  /// In en, this message translates to:
  /// **'AI Conversation Style'**
  String get aiConversationStyle;

  /// No description provided for @aiConversationStyleDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how the AI assistant responds to you'**
  String get aiConversationStyleDesc;

  /// No description provided for @aiFriendly.
  ///
  /// In en, this message translates to:
  /// **'Friendly'**
  String get aiFriendly;

  /// No description provided for @aiFriendlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses a warm and friendly tone'**
  String get aiFriendlyDesc;

  /// No description provided for @aiProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get aiProfessional;

  /// No description provided for @aiProfessionalDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses a formal and informative tone'**
  String get aiProfessionalDesc;

  /// No description provided for @aiFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get aiFun;

  /// No description provided for @aiFunDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses a playful and fun tone'**
  String get aiFunDesc;

  /// No description provided for @aiCompassionate.
  ///
  /// In en, this message translates to:
  /// **'Compassionate'**
  String get aiCompassionate;

  /// No description provided for @aiCompassionateDesc.
  ///
  /// In en, this message translates to:
  /// **'Uses a caring and protective tone'**
  String get aiCompassionateDesc;

  /// No description provided for @voiceSettings.
  ///
  /// In en, this message translates to:
  /// **'Voice Settings'**
  String get voiceSettings;

  /// No description provided for @voiceSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage AI voice features'**
  String get voiceSettingsDesc;

  /// No description provided for @voiceAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto Voice Response'**
  String get voiceAuto;

  /// No description provided for @voiceAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically read AI responses aloud'**
  String get voiceAutoDesc;

  /// No description provided for @voiceListenFeature.
  ///
  /// In en, this message translates to:
  /// **'Voice Listen Feature'**
  String get voiceListenFeature;

  /// No description provided for @voiceListenFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'You can listen to any AI response by pressing the \'Listen\' button under each AI message. You can listen manually even if auto voice is off.'**
  String get voiceListenFeatureDesc;

  /// No description provided for @voiceTTS.
  ///
  /// In en, this message translates to:
  /// **'Voice Response (TTS)'**
  String get voiceTTS;

  /// No description provided for @voiceSpeaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker (Voice)'**
  String get voiceSpeaker;

  /// No description provided for @voiceRate.
  ///
  /// In en, this message translates to:
  /// **'Speech Rate'**
  String get voiceRate;

  /// No description provided for @voicePitch.
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get voicePitch;

  /// No description provided for @notificationsSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationsSound;

  /// No description provided for @notificationsDefault.
  ///
  /// In en, this message translates to:
  /// **'Default Sound'**
  String get notificationsDefault;

  /// No description provided for @notificationsCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Notification Sound'**
  String get notificationsCustom;

  /// No description provided for @notificationsBell.
  ///
  /// In en, this message translates to:
  /// **'Bell Sound'**
  String get notificationsBell;

  /// No description provided for @notificationsChime.
  ///
  /// In en, this message translates to:
  /// **'Chime Sound'**
  String get notificationsChime;

  /// No description provided for @notificationsAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert Sound'**
  String get notificationsAlert;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @autoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Auto Update'**
  String get autoUpdate;

  /// No description provided for @autoUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically update pet statuses'**
  String get autoUpdateDesc;

  /// No description provided for @petTypeDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get petTypeDog;

  /// No description provided for @petTypeCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get petTypeCat;

  /// No description provided for @petTypeBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get petTypeBird;

  /// No description provided for @petTypeFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get petTypeFish;

  /// No description provided for @petTypeHamster.
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get petTypeHamster;

  /// No description provided for @petTypeRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get petTypeRabbit;

  /// No description provided for @petTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get petTypeOther;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @statusInfo.
  ///
  /// In en, this message translates to:
  /// **'Status Info'**
  String get statusInfo;

  /// No description provided for @satiety.
  ///
  /// In en, this message translates to:
  /// **'Satiety'**
  String get satiety;

  /// No description provided for @happiness.
  ///
  /// In en, this message translates to:
  /// **'Happiness'**
  String get happiness;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get maintenance;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @pet.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get pet;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @care.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get care;

  /// No description provided for @breed.
  ///
  /// In en, this message translates to:
  /// **'Breed'**
  String get breed;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Shows the age in years, e.g. 3 years old.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(Object age);

  /// Birth date label with day, month, year.
  ///
  /// In en, this message translates to:
  /// **'Birth Date: {day}/{month}/{year}'**
  String birthDate(Object day, Object month, Object year);

  /// No description provided for @hunger.
  ///
  /// In en, this message translates to:
  /// **'Hunger'**
  String get hunger;

  /// No description provided for @veterinaryProcedures.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Procedures'**
  String get veterinaryProcedures;

  /// No description provided for @veterinaryAppointment.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Appointment'**
  String get veterinaryAppointment;

  /// No description provided for @vaccineInformation.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Information'**
  String get vaccineInformation;

  /// No description provided for @vaccinesToBeTaken.
  ///
  /// In en, this message translates to:
  /// **'Vaccines to be Taken'**
  String get vaccinesToBeTaken;

  /// No description provided for @completedVaccines.
  ///
  /// In en, this message translates to:
  /// **'Completed Vaccines'**
  String get completedVaccines;

  /// No description provided for @coOwnerManagement.
  ///
  /// In en, this message translates to:
  /// **'Co-owner Management'**
  String get coOwnerManagement;

  /// No description provided for @diaryChat.
  ///
  /// In en, this message translates to:
  /// **'Diary Chat'**
  String get diaryChat;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessages;

  /// No description provided for @writeMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a message...'**
  String get writeMessage;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirm;

  /// No description provided for @noteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted successfully!'**
  String get noteDeleted;

  /// Note deletion error message.
  ///
  /// In en, this message translates to:
  /// **'Error deleting note: {error}'**
  String noteDeleteError(Object error);

  /// No description provided for @deletePet.
  ///
  /// In en, this message translates to:
  /// **'Delete Pet'**
  String get deletePet;

  /// No description provided for @deletePetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this pet? This action cannot be undone.'**
  String get deletePetConfirm;

  /// No description provided for @petDeleted.
  ///
  /// In en, this message translates to:
  /// **'Pet deleted successfully!'**
  String get petDeleted;

  /// Pet deletion error message.
  ///
  /// In en, this message translates to:
  /// **'Error deleting pet: {error}'**
  String petDeleteError(Object error);

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorOccurred(Object error);

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @settingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsSection;

  /// No description provided for @infoSupportSection.
  ///
  /// In en, this message translates to:
  /// **'Info & Support'**
  String get infoSupportSection;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'This app is designed to make it easy to care for your pets, track vaccinations, take daily notes, and chat with AI.'**
  String get aboutDescription;

  /// No description provided for @ttsTurkishNotFound.
  ///
  /// In en, this message translates to:
  /// **'Turkish TTS language not found, using English instead'**
  String get ttsTurkishNotFound;

  /// No description provided for @ttsServiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice service could not be started'**
  String get ttsServiceFailed;

  /// No description provided for @speechNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition is not enabled'**
  String get speechNotEnabled;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PatiTakip!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Your comprehensive pet care companion. Track health, vaccinations, daily activities, and get AI-powered advice.'**
  String get onboardingDescription;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @addPet.
  ///
  /// In en, this message translates to:
  /// **'Add Pet'**
  String get addPet;

  /// No description provided for @addPetDescription.
  ///
  /// In en, this message translates to:
  /// **'Create detailed pet profiles with photos, breed info, and personalized care schedules. Monitor multiple pets with ease.'**
  String get addPetDescription;

  /// No description provided for @vaccinationAndCare.
  ///
  /// In en, this message translates to:
  /// **'Health & Vaccination Tracking'**
  String get vaccinationAndCare;

  /// No description provided for @vaccinationAndCareDescription.
  ///
  /// In en, this message translates to:
  /// **'Never miss important vaccinations again. Set reminders, track medical history, and maintain complete health records.'**
  String get vaccinationAndCareDescription;

  /// No description provided for @profileAndHistory.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant & Analytics'**
  String get profileAndHistory;

  /// No description provided for @profileAndHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Chat with AI for pet care advice, track daily activities, and analyze your pet\'s health patterns over time.'**
  String get profileAndHistoryDescription;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get start;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get validEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @min6Chars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters.'**
  String get min6Chars;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'No account? Register'**
  String get noAccountRegister;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get enterName;

  /// No description provided for @alreadyAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyAccountLogin;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetMailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent!'**
  String get resetMailSent;

  /// No description provided for @resetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get resetPasswordButton;

  /// No description provided for @editPet.
  ///
  /// In en, this message translates to:
  /// **'Edit Pet'**
  String get editPet;

  /// No description provided for @enterPetInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter your pet\'s information.'**
  String get enterPetInfo;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @petType.
  ///
  /// In en, this message translates to:
  /// **'Pet Type'**
  String get petType;

  /// No description provided for @selectPetType.
  ///
  /// In en, this message translates to:
  /// **'Select pet type'**
  String get selectPetType;

  /// No description provided for @enterBreed.
  ///
  /// In en, this message translates to:
  /// **'Please enter breed.'**
  String get enterBreed;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select birth date'**
  String get selectBirthDate;

  /// No description provided for @intervalSettings.
  ///
  /// In en, this message translates to:
  /// **'Interval Settings'**
  String get intervalSettings;

  /// No description provided for @satietyInterval.
  ///
  /// In en, this message translates to:
  /// **'Satiety Interval'**
  String get satietyInterval;

  /// No description provided for @happinessInterval.
  ///
  /// In en, this message translates to:
  /// **'Happiness Interval'**
  String get happinessInterval;

  /// No description provided for @energyInterval.
  ///
  /// In en, this message translates to:
  /// **'Energy Interval'**
  String get energyInterval;

  /// No description provided for @careInterval.
  ///
  /// In en, this message translates to:
  /// **'Care Interval'**
  String get careInterval;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @feedingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeding Time:'**
  String get feedingTimeLabel;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateLabel;

  /// No description provided for @petCareNotifications.
  ///
  /// In en, this message translates to:
  /// **'Pet care notifications'**
  String get petCareNotifications;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @playInteractionSounds.
  ///
  /// In en, this message translates to:
  /// **'Play interaction sounds'**
  String get playInteractionSounds;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @myPets.
  ///
  /// In en, this message translates to:
  /// **'My Pets'**
  String get myPets;

  /// No description provided for @manageYourPets.
  ///
  /// In en, this message translates to:
  /// **'Manage your pets'**
  String get manageYourPets;

  /// No description provided for @petsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading pets...'**
  String get petsLoading;

  /// No description provided for @noPetsAdded.
  ///
  /// In en, this message translates to:
  /// **'No pets added yet!'**
  String get noPetsAdded;

  /// No description provided for @addPetHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first pet.'**
  String get addPetHint;

  /// No description provided for @feedingTimeSaved.
  ///
  /// In en, this message translates to:
  /// **'Feeding time saved!'**
  String get feedingTimeSaved;

  /// No description provided for @vaccinesTaken.
  ///
  /// In en, this message translates to:
  /// **'Vaccines taken'**
  String get vaccinesTaken;

  /// No description provided for @askQuestionChat.
  ///
  /// In en, this message translates to:
  /// **'Ask a question in chat'**
  String get askQuestionChat;

  /// No description provided for @owners.
  ///
  /// In en, this message translates to:
  /// **'Owners'**
  String get owners;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @noChatYet.
  ///
  /// In en, this message translates to:
  /// **'No chat yet'**
  String get noChatYet;

  /// No description provided for @newChatStarted.
  ///
  /// In en, this message translates to:
  /// **'New chat started'**
  String get newChatStarted;

  /// Message count with number placeholder.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String messageCount(Object count);

  /// No description provided for @newChatConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChatConfirmTitle;

  /// No description provided for @newChatConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Current chat history will be saved and a new chat will be started. Do you want to continue?'**
  String get newChatConfirmMessage;

  /// No description provided for @clearChatConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Current chat history will be permanently deleted. This action cannot be undone. Do you want to continue?'**
  String get clearChatConfirmMessage;

  /// No description provided for @imageSent.
  ///
  /// In en, this message translates to:
  /// **'Image sent'**
  String get imageSent;

  /// No description provided for @voiceMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Voice message sent'**
  String get voiceMessageSent;

  /// No description provided for @speakQuestion.
  ///
  /// In en, this message translates to:
  /// **'Speak your question'**
  String get speakQuestion;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get chatHint;

  /// No description provided for @feedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get feedbackThanks;

  /// No description provided for @feedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Let us know your thoughts or issues.'**
  String get feedbackDescription;

  /// No description provided for @yourMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get yourMessage;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message.'**
  String get enterMessage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @doneVaccineAdd.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get doneVaccineAdd;

  /// No description provided for @vaccineAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Vaccine'**
  String get vaccineAdd;

  /// No description provided for @vaccineName.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Name'**
  String get vaccineName;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @doneVaccines.
  ///
  /// In en, this message translates to:
  /// **'Completed Vaccines'**
  String get doneVaccines;

  /// No description provided for @vaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get vaccines;

  /// No vaccines message, can be parameterized if needed.
  ///
  /// In en, this message translates to:
  /// **'No {type} vaccines yet'**
  String noVaccines(Object showDone, Object type);

  /// Date label with value.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String date(Object date);

  /// Delete pet error message.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete pet: {error}'**
  String deletePetError(Object error);

  /// Generic error message.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// Delete profile error message.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile: {error}'**
  String deleteProfileError(Object error);

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 PatiTakip'**
  String get copyright;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutConfirm;

  /// No description provided for @deleteProfile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// No description provided for @deleteProfileConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your profile?'**
  String get deleteProfileConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @emailVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Email Verification Required'**
  String get emailVerificationRequired;

  /// No description provided for @emailVerificationDescription.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your email address'**
  String get emailVerificationDescription;

  /// No description provided for @redirectingToLogin.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to login screen...'**
  String get redirectingToLogin;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email not found'**
  String get emailNotFound;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get nameRequired;

  /// No description provided for @nameMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get nameMinLengthError;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile: {error}'**
  String profileUpdateError(Object error);

  /// No description provided for @profileUpdateErrorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get profileUpdateErrorPlaceholder;

  /// No description provided for @profileDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile deleted successfully'**
  String get profileDeletedSuccessfully;

  /// No description provided for @profileDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Error deleting profile: {error}'**
  String profileDeleteError(Object error);

  /// No description provided for @profileDeleteErrorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'error'**
  String get profileDeleteErrorPlaceholder;

  /// No description provided for @selectFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get selectFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @vaccineTime.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Time'**
  String get vaccineTime;

  /// No description provided for @statusInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Status Information'**
  String get statusInfoTitle;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @dog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get dog;

  /// No description provided for @cat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get cat;

  /// No description provided for @bird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get bird;

  /// No description provided for @fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get fish;

  /// No description provided for @hamster.
  ///
  /// In en, this message translates to:
  /// **'Hamster'**
  String get hamster;

  /// No description provided for @rabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get rabbit;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @useRecognizedText.
  ///
  /// In en, this message translates to:
  /// **'Use This Text'**
  String get useRecognizedText;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqDescription.
  ///
  /// In en, this message translates to:
  /// **'Common questions and answers about the app'**
  String get faqDescription;

  /// No description provided for @faqSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search questions...'**
  String get faqSearchHint;

  /// No description provided for @faqStillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get faqStillNeedHelp;

  /// No description provided for @faqContactSupportTeam.
  ///
  /// In en, this message translates to:
  /// **'Contact our support team'**
  String get faqContactSupportTeam;

  /// No description provided for @faqEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get faqEmail;

  /// No description provided for @faqFeedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get faqFeedback;

  /// No description provided for @faqEmailDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get faqEmailDialogTitle;

  /// No description provided for @faqEmailDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Your email app will open and you can send a message to info@patitakip.com'**
  String get faqEmailDialogContent;

  /// No description provided for @faqGeneral.
  ///
  /// In en, this message translates to:
  /// **'General Questions'**
  String get faqGeneral;

  /// No description provided for @faqFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get faqFeatures;

  /// No description provided for @faqPetCareHealth.
  ///
  /// In en, this message translates to:
  /// **'Pet Care & Health'**
  String get faqPetCareHealth;

  /// No description provided for @faqPetLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Pet Lifestyle'**
  String get faqPetLifestyle;

  /// No description provided for @faqTravelSocial.
  ///
  /// In en, this message translates to:
  /// **'Travel & Social'**
  String get faqTravelSocial;

  /// No description provided for @faqTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical Questions'**
  String get faqTechnical;

  /// No description provided for @faqSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get faqSupport;

  /// No description provided for @faqWhatIsPatiTakip.
  ///
  /// In en, this message translates to:
  /// **'What is PatiTakip?'**
  String get faqWhatIsPatiTakip;

  /// No description provided for @faqWhatIsPatiTakipAnswer.
  ///
  /// In en, this message translates to:
  /// **'PatiTakip is a comprehensive mobile app designed to make pet care easier. It offers vaccination tracking, daily notes, and AI-powered chat features.'**
  String get faqWhatIsPatiTakipAnswer;

  /// No description provided for @faqHowToAddPet.
  ///
  /// In en, this message translates to:
  /// **'How do I add a pet?'**
  String get faqHowToAddPet;

  /// No description provided for @faqHowToAddPetAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can add a new pet by clicking the + button on the main page. You need to enter basic information such as pet type, breed, gender, and birth date.'**
  String get faqHowToAddPetAnswer;

  /// No description provided for @faqHowToTrackVaccines.
  ///
  /// In en, this message translates to:
  /// **'How do I track vaccinations?'**
  String get faqHowToTrackVaccines;

  /// No description provided for @faqHowToTrackVaccinesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Go to the \'Vaccines\' tab on the pet detail page to add new vaccines or view existing ones. You can mark completed vaccines as done.'**
  String get faqHowToTrackVaccinesAnswer;

  /// No description provided for @faqHowToUseAI.
  ///
  /// In en, this message translates to:
  /// **'How do I use the AI chat feature?'**
  String get faqHowToUseAI;

  /// No description provided for @faqHowToUseAIAnswer.
  ///
  /// In en, this message translates to:
  /// **'Click the AI button in the bottom right corner of the main page to chat with artificial intelligence. You can ask questions in writing.'**
  String get faqHowToUseAIAnswer;

  /// No description provided for @faqVoiceCommands.
  ///
  /// In en, this message translates to:
  /// **'How do voice commands work?'**
  String get faqVoiceCommands;

  /// No description provided for @faqVoiceCommandsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Press the microphone button on the AI chat page to ask questions by voice. The app converts your voice to text and AI responds.'**
  String get faqVoiceCommandsAnswer;

  /// No description provided for @faqNotifications.
  ///
  /// In en, this message translates to:
  /// **'How do I set up notifications?'**
  String get faqNotifications;

  /// No description provided for @faqNotificationsAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can manage your notification preferences in Settings > Notifications. You can receive notifications for vaccination times.'**
  String get faqNotificationsAnswer;

  /// No description provided for @faqDataBackup.
  ///
  /// In en, this message translates to:
  /// **'Is my data safe?'**
  String get faqDataBackup;

  /// No description provided for @faqDataBackupAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, all your data is stored securely on Firebase cloud servers. Your data is always accessible when you log into your account.'**
  String get faqDataBackupAnswer;

  /// No description provided for @faqMultiplePets.
  ///
  /// In en, this message translates to:
  /// **'Can I add multiple pets?'**
  String get faqMultiplePets;

  /// No description provided for @faqMultiplePetsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can add as many pets as you want. Each pet has its own profile and tracking system.'**
  String get faqMultiplePetsAnswer;

  /// No description provided for @faqShareAccount.
  ///
  /// In en, this message translates to:
  /// **'Can I share my account with others?'**
  String get faqShareAccount;

  /// No description provided for @faqShareAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can add other users from the \'Co-owner Management\' section on the pet detail page. This way family members can also participate in pet care.'**
  String get faqShareAccountAnswer;

  /// No description provided for @faqAppUpdates.
  ///
  /// In en, this message translates to:
  /// **'How do app updates work?'**
  String get faqAppUpdates;

  /// No description provided for @faqAppUpdatesAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can set up automatic update settings in Settings > Update. New features and improvements are added regularly.'**
  String get faqAppUpdatesAnswer;

  /// No description provided for @faqContactSupport.
  ///
  /// In en, this message translates to:
  /// **'How can I contact the support team?'**
  String get faqContactSupport;

  /// No description provided for @faqContactSupportAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can contact our support team using the \'Send Feedback\' section on this page or by sending an email directly.'**
  String get faqContactSupportAnswer;

  /// No description provided for @faqPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'What is the privacy policy?'**
  String get faqPrivacyPolicy;

  /// No description provided for @faqPrivacyPolicyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your personal data is securely protected and not shared with third parties. Our privacy policy is available on our website.'**
  String get faqPrivacyPolicyAnswer;

  /// No description provided for @faqTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'What are the terms of service?'**
  String get faqTermsOfService;

  /// No description provided for @faqTermsOfServiceAnswer.
  ///
  /// In en, this message translates to:
  /// **'By using the app, you accept our terms of service. You can find the full text on our website.'**
  String get faqTermsOfServiceAnswer;

  /// No description provided for @faqAppFree.
  ///
  /// In en, this message translates to:
  /// **'Is the app free?'**
  String get faqAppFree;

  /// No description provided for @faqAppFreeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, PatiTakip is completely free. All basic features are available to everyone.'**
  String get faqAppFreeAnswer;

  /// No description provided for @faqDeviceSupport.
  ///
  /// In en, this message translates to:
  /// **'Which devices does it work on?'**
  String get faqDeviceSupport;

  /// No description provided for @faqDeviceSupportAnswer.
  ///
  /// In en, this message translates to:
  /// **'PatiTakip currently only works on Android devices.'**
  String get faqDeviceSupportAnswer;

  /// No description provided for @faqMultiUserSupport.
  ///
  /// In en, this message translates to:
  /// **'How does multi-user support work?'**
  String get faqMultiUserSupport;

  /// No description provided for @faqMultiUserSupportAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can add other users from the \'Co-owner Management\' section on the pet detail page. This way family members can also participate in pet care and access the same information.'**
  String get faqMultiUserSupportAnswer;

  /// No description provided for @faqDataSecurity.
  ///
  /// In en, this message translates to:
  /// **'Is my data secure?'**
  String get faqDataSecurity;

  /// No description provided for @faqDataSecurityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, all your data is stored securely on Firebase cloud servers with encryption. Your data is always accessible when you log into your account.'**
  String get faqDataSecurityAnswer;

  /// No description provided for @faqPetWeight.
  ///
  /// In en, this message translates to:
  /// **'Can I track my pet\'s weight?'**
  String get faqPetWeight;

  /// No description provided for @faqPetWeightAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can record your pet\'s weight in notes. This way you can track weight changes and monitor health status.'**
  String get faqPetWeightAnswer;

  /// No description provided for @faqVetAppointments.
  ///
  /// In en, this message translates to:
  /// **'Can I track vet appointments?'**
  String get faqVetAppointments;

  /// No description provided for @faqVetAppointmentsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can record vet appointments in notes.'**
  String get faqVetAppointmentsAnswer;

  /// No description provided for @faqPetSleep.
  ///
  /// In en, this message translates to:
  /// **'Can I track my pet\'s sleep schedule?'**
  String get faqPetSleep;

  /// No description provided for @faqPetSleepAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can record your pet\'s sleep schedule in notes. You can take notes about sleep duration and quality.'**
  String get faqPetSleepAnswer;

  /// No description provided for @faqPetSocial.
  ///
  /// In en, this message translates to:
  /// **'How can I record social activities?'**
  String get faqPetSocial;

  /// No description provided for @faqPetSocialAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can record your pet\'s playtime with other animals, park visits, and social activities in notes.'**
  String get faqPetSocialAnswer;

  /// No description provided for @faqVaccineRequirements.
  ///
  /// In en, this message translates to:
  /// **'Can I get information about vaccine requirements in different countries?'**
  String get faqVaccineRequirements;

  /// No description provided for @faqVaccineRequirementsAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can get general information using the AI chat feature, but we always recommend checking official veterinary sources.'**
  String get faqVaccineRequirementsAnswer;

  /// No description provided for @faqOfflineUse.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app without internet connection?'**
  String get faqOfflineUse;

  /// No description provided for @faqOfflineUseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Basic features work limitedly offline, but internet connection is required for data synchronization and AI chat.'**
  String get faqOfflineUseAnswer;

  /// No description provided for @faqDataExport.
  ///
  /// In en, this message translates to:
  /// **'Can I export my data?'**
  String get faqDataExport;

  /// No description provided for @faqDataExportAnswer.
  ///
  /// In en, this message translates to:
  /// **'No, data export feature is not currently available.'**
  String get faqDataExportAnswer;

  /// No description provided for @faqAppSize.
  ///
  /// In en, this message translates to:
  /// **'How much space does the app take?'**
  String get faqAppSize;

  /// No description provided for @faqAppSizeAnswer.
  ///
  /// In en, this message translates to:
  /// **'PatiTakip takes approximately 50-100 MB. Photos are stored in the cloud so they don\'t take much space on your device.'**
  String get faqAppSizeAnswer;

  /// No description provided for @faqBugReport.
  ///
  /// In en, this message translates to:
  /// **'How can I send a bug report?'**
  String get faqBugReport;

  /// No description provided for @faqBugReportAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can send bug reports using the \'Feedback\' section in the app. If you provide detailed descriptions, we can help you faster.'**
  String get faqBugReportAnswer;

  /// No description provided for @faqFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'How can I suggest features?'**
  String get faqFeatureRequest;

  /// No description provided for @faqFeatureRequestAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can send new feature suggestions through the \'Feedback\' section. All suggestions are evaluated and the most popular ones are developed.'**
  String get faqFeatureRequestAnswer;

  /// No description provided for @faqCommunityForum.
  ///
  /// In en, this message translates to:
  /// **'Is there a community forum?'**
  String get faqCommunityForum;

  /// No description provided for @faqCommunityForumAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, a community forum for PatiTakip users will open soon. You can share your experiences and get advice from other users there.'**
  String get faqCommunityForumAnswer;

  /// No description provided for @faqPetHealth.
  ///
  /// In en, this message translates to:
  /// **'How can I track my pet\'s health?'**
  String get faqPetHealth;

  /// No description provided for @faqPetHealthAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can track your pet\'s health by monitoring their daily activities, setting vaccination reminders, and recording veterinary visits in the app.'**
  String get faqPetHealthAnswer;

  /// No description provided for @faqPetPhotos.
  ///
  /// In en, this message translates to:
  /// **'Can I add photos to my pet\'s profile?'**
  String get faqPetPhotos;

  /// No description provided for @faqPetPhotosAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can add multiple photos to your pet\'s profile and update them anytime to keep track of their growth and changes.'**
  String get faqPetPhotosAnswer;

  /// No description provided for @faqPetNotes.
  ///
  /// In en, this message translates to:
  /// **'How do I add notes about my pet?'**
  String get faqPetNotes;

  /// No description provided for @faqPetNotesAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can add text, voice, and visual notes about your pet\'s behavior, health, or special moments using the note features in the app.'**
  String get faqPetNotesAnswer;

  /// No description provided for @faqPetReminders.
  ///
  /// In en, this message translates to:
  /// **'Can I set reminders for pet care?'**
  String get faqPetReminders;

  /// No description provided for @faqPetRemindersAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can set reminders for vaccinations, vet appointments, grooming, feeding, and other important pet care activities.'**
  String get faqPetRemindersAnswer;

  /// No description provided for @faqPetTraining.
  ///
  /// In en, this message translates to:
  /// **'Does the app help with pet training?'**
  String get faqPetTraining;

  /// No description provided for @faqPetTrainingAnswer.
  ///
  /// In en, this message translates to:
  /// **'The AI assistant can provide training tips and advice, but for complex training issues, we recommend consulting with a professional trainer.'**
  String get faqPetTrainingAnswer;

  /// No description provided for @faqPetEmergency.
  ///
  /// In en, this message translates to:
  /// **'What should I do in a pet emergency?'**
  String get faqPetEmergency;

  /// No description provided for @faqPetEmergencyAnswer.
  ///
  /// In en, this message translates to:
  /// **'In case of emergency, contact your veterinarian immediately. The app can help you keep emergency contact information easily accessible.'**
  String get faqPetEmergencyAnswer;

  /// No description provided for @faqPetTravel.
  ///
  /// In en, this message translates to:
  /// **'How can I prepare my pet for travel?'**
  String get faqPetTravel;

  /// No description provided for @faqPetTravelAnswer.
  ///
  /// In en, this message translates to:
  /// **'The app can help you prepare travel checklists, ensure vaccinations are up to date, and keep important documents organized.'**
  String get faqPetTravelAnswer;

  /// No description provided for @faqPetGrooming.
  ///
  /// In en, this message translates to:
  /// **'How often should I groom my pet?'**
  String get faqPetGrooming;

  /// No description provided for @faqPetGroomingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Grooming frequency depends on your pet\'s breed, coat type, and lifestyle. The AI assistant can provide specific recommendations for your pet.'**
  String get faqPetGroomingAnswer;

  /// No description provided for @faqPetExercise.
  ///
  /// In en, this message translates to:
  /// **'How much exercise does my pet need?'**
  String get faqPetExercise;

  /// No description provided for @faqPetExerciseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Exercise needs vary by breed, age, and health. The app can help you create personalized exercise plans and track activity levels.'**
  String get faqPetExerciseAnswer;

  /// No description provided for @faqPetDiet.
  ///
  /// In en, this message translates to:
  /// **'What should I feed my pet?'**
  String get faqPetDiet;

  /// No description provided for @faqPetDietAnswer.
  ///
  /// In en, this message translates to:
  /// **'Diet recommendations depend on your pet\'s age, breed, health, and activity level. Consult with your veterinarian for personalized nutrition advice.'**
  String get faqPetDietAnswer;

  /// No description provided for @aiChatInstructions.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about pet care, health, training, or general questions. I\'m here to help!'**
  String get aiChatInstructions;

  /// No description provided for @aiChatInstructionsWithPet.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about {petName}\'s care, health, training, or general pet questions. I\'m here to help!'**
  String aiChatInstructionsWithPet(Object petName);

  /// No description provided for @aiChatInstructionsWithPetPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'petName'**
  String get aiChatInstructionsWithPetPlaceholder;

  /// Voice message with duration placeholder
  ///
  /// In en, this message translates to:
  /// **'Voice Message'**
  String voiceMessage(Object duration);

  /// Voice message error with error placeholder
  ///
  /// In en, this message translates to:
  /// **'Voice message could not be sent: {error}'**
  String voiceMessageError(Object error);

  /// No description provided for @imageNoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Image note added!'**
  String get imageNoteAdded;

  /// Image note error with error placeholder
  ///
  /// In en, this message translates to:
  /// **'Image note could not be added: {error}'**
  String imageNoteError(Object error);

  /// Image note with text and note placeholder
  ///
  /// In en, this message translates to:
  /// **'📷 Image note: {note}'**
  String imageNoteWithText(Object note);

  /// No description provided for @imageNoteAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'📷 Image note added'**
  String get imageNoteAddedMessage;

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get unknownTime;

  /// No description provided for @noVaccinesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'type'**
  String get noVaccinesPlaceholder;

  /// No description provided for @datePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'date'**
  String get datePlaceholder;

  /// No description provided for @markAsDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as Done'**
  String get markAsDone;

  /// No description provided for @messaging.
  ///
  /// In en, this message translates to:
  /// **'Messaging'**
  String get messaging;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'coowner@email.com'**
  String get emailHint;

  /// No description provided for @addNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add note (optional)'**
  String get addNoteOptional;

  /// No description provided for @birthdayCongratulations.
  ///
  /// In en, this message translates to:
  /// **'Happy Birthday!'**
  String get birthdayCongratulations;

  /// No description provided for @birthdayCongratulationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Happy Birthday {name}!'**
  String birthdayCongratulationsMessage(Object name);

  /// No description provided for @birthdayCongratulationsMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'name'**
  String get birthdayCongratulationsMessagePlaceholder;

  /// No description provided for @youAreOwner.
  ///
  /// In en, this message translates to:
  /// **'You are the owner'**
  String get youAreOwner;

  /// No description provided for @youAreNotOwner.
  ///
  /// In en, this message translates to:
  /// **'You are not the owner'**
  String get youAreNotOwner;

  /// No description provided for @statusInformation.
  ///
  /// In en, this message translates to:
  /// **'Status Information'**
  String get statusInformation;

  /// No description provided for @onlineCoOwner.
  ///
  /// In en, this message translates to:
  /// **'1 co-owner online'**
  String get onlineCoOwner;

  /// No description provided for @petTrackingApp.
  ///
  /// In en, this message translates to:
  /// **'Pet Tracking Application'**
  String get petTrackingApp;

  /// No description provided for @appSharingMessage.
  ///
  /// In en, this message translates to:
  /// **'🐾 {appTitle} - The best care experience for your pets! Share the app with your friends.'**
  String appSharingMessage(Object appTitle);

  /// No description provided for @appSharingMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'appTitle'**
  String get appSharingMessagePlaceholder;

  /// No description provided for @onboardingFeature1.
  ///
  /// In en, this message translates to:
  /// **'Pet Management'**
  String get onboardingFeature1;

  /// No description provided for @onboardingFeature2.
  ///
  /// In en, this message translates to:
  /// **'Health Tracking'**
  String get onboardingFeature2;

  /// No description provided for @onboardingFeature3.
  ///
  /// In en, this message translates to:
  /// **'Vaccine Reminders'**
  String get onboardingFeature3;

  /// No description provided for @onboardingFeature4.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Appointments'**
  String get onboardingFeature4;

  /// No description provided for @onboardingFeature5.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Chat'**
  String get onboardingFeature5;

  /// No description provided for @onboardingFeature9.
  ///
  /// In en, this message translates to:
  /// **'Multi-User Support'**
  String get onboardingFeature9;

  /// No description provided for @onboardingFeature10.
  ///
  /// In en, this message translates to:
  /// **'Voice Messaging'**
  String get onboardingFeature10;

  /// No description provided for @onboardingFeature11.
  ///
  /// In en, this message translates to:
  /// **'Notification System'**
  String get onboardingFeature11;

  /// No description provided for @onboardingFeature12.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup'**
  String get onboardingFeature12;

  /// No description provided for @onboardingFeature13.
  ///
  /// In en, this message translates to:
  /// **'Multi-Platform'**
  String get onboardingFeature13;

  /// No description provided for @onboardingFeature14.
  ///
  /// In en, this message translates to:
  /// **'Turkish/English Language'**
  String get onboardingFeature14;

  /// No description provided for @onboardingFeature15.
  ///
  /// In en, this message translates to:
  /// **'Light/Dark Theme'**
  String get onboardingFeature15;

  /// No description provided for @petManagement.
  ///
  /// In en, this message translates to:
  /// **'Pet Management'**
  String get petManagement;

  /// No description provided for @petManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage all your pet information in one place'**
  String get petManagementDescription;

  /// No description provided for @healthTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily track health status and vaccination schedules'**
  String get healthTrackingDescription;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get loginToYourAccount;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short (minimum 6 characters)'**
  String get passwordTooShort;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'A password reset link will be sent to your email address'**
  String get resetPasswordDescription;

  /// No description provided for @coOwnerRequestsLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading co-owner requests'**
  String get coOwnerRequestsLoadingError;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get requestAccepted;

  /// No description provided for @requestAcceptError.
  ///
  /// In en, this message translates to:
  /// **'Error accepting request'**
  String get requestAcceptError;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get rejectRequest;

  /// No description provided for @rejectRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this request?'**
  String get rejectRequestConfirm;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @coOwnersLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Error loading co-owners'**
  String get coOwnersLoadingError;

  /// No description provided for @petNotFound.
  ///
  /// In en, this message translates to:
  /// **'Pet not found. Please refresh the page.'**
  String get petNotFound;

  /// No description provided for @startChattingWithCoOwners.
  ///
  /// In en, this message translates to:
  /// **'Start chatting with co-owners'**
  String get startChattingWithCoOwners;

  /// No description provided for @editAppointment.
  ///
  /// In en, this message translates to:
  /// **'Edit Appointment'**
  String get editAppointment;

  /// No description provided for @coOwnerManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage users who share your pet'**
  String get coOwnerManagementDescription;

  /// No description provided for @addImageNote.
  ///
  /// In en, this message translates to:
  /// **'Add Image Note'**
  String get addImageNote;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @vaccineTimeMessage.
  ///
  /// In en, this message translates to:
  /// **'Vaccine time!'**
  String get vaccineTimeMessage;

  /// No description provided for @selectDateAndTime.
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get selectDateAndTime;

  /// No description provided for @clearCurrentChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Current Chat'**
  String get clearCurrentChat;

  /// No description provided for @noChatHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No chat history yet'**
  String get noChatHistoryYet;

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @copyrightText.
  ///
  /// In en, this message translates to:
  /// **'© 2025 {appTitle} - All rights reserved'**
  String copyrightText(Object appTitle);

  /// No description provided for @copyrightTextPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'appTitle'**
  String get copyrightTextPlaceholder;

  /// No description provided for @appAboutSubject.
  ///
  /// In en, this message translates to:
  /// **'{appTitle} App Information'**
  String appAboutSubject(Object appTitle);

  /// No description provided for @appAboutSubjectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'appTitle'**
  String get appAboutSubjectPlaceholder;

  /// No description provided for @whatsappMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, I would like to get information about the {appTitle} app.'**
  String whatsappMessage(Object appTitle);

  /// No description provided for @whatsappMessagePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'appTitle'**
  String get whatsappMessagePlaceholder;

  /// No description provided for @languageSupport.
  ///
  /// In en, this message translates to:
  /// **'🌐 Turkish/English language support'**
  String get languageSupport;

  /// No description provided for @appInfoAndFeatures.
  ///
  /// In en, this message translates to:
  /// **'App Information and Features'**
  String get appInfoAndFeatures;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @coOwnerRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Co-owner request sent'**
  String get coOwnerRequestSent;

  /// No description provided for @messageSendingError.
  ///
  /// In en, this message translates to:
  /// **'Error sending message'**
  String get messageSendingError;

  /// No description provided for @voiceRecordingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Voice recording completed'**
  String get voiceRecordingCompleted;

  /// No description provided for @addCoOwner.
  ///
  /// In en, this message translates to:
  /// **'Add Co-owner'**
  String get addCoOwner;

  /// No description provided for @coOwners.
  ///
  /// In en, this message translates to:
  /// **'Co-owners'**
  String get coOwners;

  /// No description provided for @noCoOwnersYet.
  ///
  /// In en, this message translates to:
  /// **'No co-owners added yet'**
  String get noCoOwnersYet;

  /// No description provided for @useFormAboveToAddCoOwner.
  ///
  /// In en, this message translates to:
  /// **'Use the form above to add co-owners'**
  String get useFormAboveToAddCoOwner;

  /// No description provided for @sendCoOwnerRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Co-owner Request'**
  String get sendCoOwnerRequest;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @mainOwner.
  ///
  /// In en, this message translates to:
  /// **'Main Owner'**
  String get mainOwner;

  /// No description provided for @anonymousUser.
  ///
  /// In en, this message translates to:
  /// **'Anonymous User'**
  String get anonymousUser;

  /// No description provided for @removeCoOwner.
  ///
  /// In en, this message translates to:
  /// **'Remove Co-owner'**
  String get removeCoOwner;

  /// No description provided for @removeCoOwnerConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this co-owner?'**
  String get removeCoOwnerConfirmation;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @coOwnerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Co-owner removed'**
  String get coOwnerRemoved;

  /// No description provided for @errorRemovingCoOwner.
  ///
  /// In en, this message translates to:
  /// **'Error removing co-owner'**
  String get errorRemovingCoOwner;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @coOwner.
  ///
  /// In en, this message translates to:
  /// **'Co-owner'**
  String get coOwner;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'minutes ago'**
  String get minutesAgo;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @aboutPageTitle.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutPageTitle;

  /// No description provided for @aboutPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App Information and Features'**
  String get aboutPageSubtitle;

  /// No description provided for @aboutFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get aboutFeaturesTitle;

  /// No description provided for @aboutFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App Information and Features'**
  String get aboutFeaturesSubtitle;

  /// No description provided for @aboutTechnologyTitle.
  ///
  /// In en, this message translates to:
  /// **'Technology Stack'**
  String get aboutTechnologyTitle;

  /// No description provided for @aboutTechnologySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built with modern technologies'**
  String get aboutTechnologySubtitle;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data is safe with us'**
  String get aboutPrivacySubtitle;

  /// No description provided for @aboutSocialTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get aboutSocialTitle;

  /// No description provided for @aboutSocialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stay connected on social media'**
  String get aboutSocialSubtitle;

  /// No description provided for @aboutContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact & Support'**
  String get aboutContactTitle;

  /// No description provided for @aboutContactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with us'**
  String get aboutContactSubtitle;

  /// No description provided for @aboutActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Actions'**
  String get aboutActionsTitle;

  /// No description provided for @aboutActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions and settings'**
  String get aboutActionsSubtitle;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'🔒 Privacy Policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutPrivacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'We protect your personal information'**
  String get aboutPrivacyPolicyDesc;

  /// No description provided for @aboutDataSecurity.
  ///
  /// In en, this message translates to:
  /// **'🛡️ Data Security'**
  String get aboutDataSecurity;

  /// No description provided for @aboutDataSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is encrypted and secure'**
  String get aboutDataSecurityDesc;

  /// No description provided for @aboutCustomerSupport.
  ///
  /// In en, this message translates to:
  /// **'📞 Customer Support'**
  String get aboutCustomerSupport;

  /// No description provided for @aboutCustomerSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'24/7 support available'**
  String get aboutCustomerSupportDesc;

  /// No description provided for @aboutSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get aboutSendEmail;

  /// No description provided for @aboutWhatsAppChat.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Chat'**
  String get aboutWhatsAppChat;

  /// No description provided for @aboutVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get aboutVisitWebsite;

  /// No description provided for @aboutRateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get aboutRateApp;

  /// No description provided for @aboutRateAppDesc.
  ///
  /// In en, this message translates to:
  /// **'If you enjoy using our app, please take a moment to rate it on the app store.'**
  String get aboutRateAppDesc;

  /// No description provided for @aboutRateNow.
  ///
  /// In en, this message translates to:
  /// **'Rate Now'**
  String get aboutRateNow;

  /// No description provided for @aboutShareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get aboutShareApp;

  /// No description provided for @aboutFollowUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get aboutFollowUs;

  /// No description provided for @aboutFollowUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with our latest news and updates by following us on social media.'**
  String get aboutFollowUsDesc;

  /// No description provided for @aboutFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get aboutFollow;

  /// No description provided for @aboutDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get aboutDeleteAccount;

  /// No description provided for @aboutDeleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get aboutDeleteAccountDesc;

  /// No description provided for @aboutDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get aboutDelete;

  /// No description provided for @aboutDeleteAccountFinal.
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get aboutDeleteAccountFinal;

  /// No description provided for @aboutDeleteAccountFinalDesc.
  ///
  /// In en, this message translates to:
  /// **'This is your final warning. Once you confirm, your account and all data will be permanently deleted.'**
  String get aboutDeleteAccountFinalDesc;

  /// No description provided for @aboutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get aboutConfirm;

  /// No description provided for @aboutAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account Deleted'**
  String get aboutAccountDeleted;

  /// No description provided for @aboutAccountDeletedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted. If you want to continue using the app, you can register again.'**
  String get aboutAccountDeletedDesc;

  /// No description provided for @aboutSocialMediaAccounts.
  ///
  /// In en, this message translates to:
  /// **'Our Social Media Accounts'**
  String get aboutSocialMediaAccounts;

  /// No description provided for @aboutClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get aboutClose;

  /// No description provided for @aboutError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get aboutError;

  /// No description provided for @aboutOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get aboutOk;

  /// No description provided for @aboutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get aboutCancel;

  /// No description provided for @aboutEmailAppNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email application not found'**
  String get aboutEmailAppNotFound;

  /// No description provided for @aboutWebsiteNotOpened.
  ///
  /// In en, this message translates to:
  /// **'Website could not be opened'**
  String get aboutWebsiteNotOpened;

  /// No description provided for @aboutWhatsAppNotOpened.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp could not be opened'**
  String get aboutWhatsAppNotOpened;

  /// No description provided for @aboutSocialMediaNotOpened.
  ///
  /// In en, this message translates to:
  /// **'{platform} could not be opened'**
  String aboutSocialMediaNotOpened(Object platform);

  /// No description provided for @aboutSocialMediaNotOpenedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'platform'**
  String get aboutSocialMediaNotOpenedPlaceholder;

  /// No description provided for @aboutAppStoreNotOpened.
  ///
  /// In en, this message translates to:
  /// **'App store could not be opened'**
  String get aboutAppStoreNotOpened;

  /// No description provided for @aboutFlutterTech.
  ///
  /// In en, this message translates to:
  /// **'Flutter 3.8+ & Dart'**
  String get aboutFlutterTech;

  /// No description provided for @aboutFirebaseTech.
  ///
  /// In en, this message translates to:
  /// **'Firebase (Auth, Firestore)'**
  String get aboutFirebaseTech;

  /// No description provided for @aboutProviderTech.
  ///
  /// In en, this message translates to:
  /// **'Provider State Management'**
  String get aboutProviderTech;

  /// No description provided for @aboutTTSTech.
  ///
  /// In en, this message translates to:
  /// **'Flutter TTS & Sound'**
  String get aboutTTSTech;

  /// No description provided for @aboutNotificationsTech.
  ///
  /// In en, this message translates to:
  /// **'Local Notifications'**
  String get aboutNotificationsTech;

  /// No description provided for @aboutMediaTech.
  ///
  /// In en, this message translates to:
  /// **'Image Picker & Media'**
  String get aboutMediaTech;

  /// No description provided for @aboutCrossPlatformTech.
  ///
  /// In en, this message translates to:
  /// **'Cross-platform Support'**
  String get aboutCrossPlatformTech;

  /// No description provided for @aboutFacebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get aboutFacebook;

  /// No description provided for @aboutInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get aboutInstagram;

  /// No description provided for @aboutTwitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get aboutTwitter;

  /// No description provided for @aboutYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get aboutYouTube;

  /// No description provided for @vetAppointmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Appointment'**
  String get vetAppointmentTitle;

  /// No description provided for @appointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Appointment date'**
  String get appointmentDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @appointmentTime.
  ///
  /// In en, this message translates to:
  /// **'Appointment time'**
  String get appointmentTime;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @appointmentNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Notes related to the appointment...'**
  String get appointmentNotesHint;

  /// No description provided for @existingAppointment.
  ///
  /// In en, this message translates to:
  /// **'Existing Appointment'**
  String get existingAppointment;

  /// No description provided for @cancelAppointment.
  ///
  /// In en, this message translates to:
  /// **'Cancel Appointment'**
  String get cancelAppointment;

  /// No description provided for @updateAppointment.
  ///
  /// In en, this message translates to:
  /// **'Update Appointment'**
  String get updateAppointment;

  /// No description provided for @saveAppointment.
  ///
  /// In en, this message translates to:
  /// **'Save Appointment'**
  String get saveAppointment;

  /// No description provided for @appointmentSaved.
  ///
  /// In en, this message translates to:
  /// **'Veterinary appointment saved for {petName}'**
  String appointmentSaved(Object petName);

  /// No description provided for @appointmentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Veterinary appointment cancelled for {petName}'**
  String appointmentCancelled(Object petName);

  /// No description provided for @vetAppointmentReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'🏥 Veterinary Appointment Reminder'**
  String get vetAppointmentReminderTitle;

  /// No description provided for @vetAppointmentReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Veterinary appointment for {petName} in 3 days! Don\'t forget to prepare.'**
  String vetAppointmentReminderBody(Object petName);

  /// No description provided for @vetAppointmentTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'🏥 Veterinary Appointment Today!'**
  String get vetAppointmentTodayTitle;

  /// No description provided for @vetAppointmentTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Veterinary appointment for {petName} today! Check the appointment time.'**
  String vetAppointmentTodayBody(Object petName);

  /// No description provided for @vetAppointmentChannelName.
  ///
  /// In en, this message translates to:
  /// **'Veterinary Appointment Notifications'**
  String get vetAppointmentChannelName;

  /// No description provided for @vetAppointmentChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Veterinary appointment reminder notifications'**
  String get vetAppointmentChannelDescription;

  /// No description provided for @coOwnerRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Co-owner Requests'**
  String get coOwnerRequestsTitle;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// No description provided for @noPendingRequestsDescription.
  ///
  /// In en, this message translates to:
  /// **'Incoming co-owner requests will appear here'**
  String get noPendingRequestsDescription;

  /// No description provided for @coOwnerRequest.
  ///
  /// In en, this message translates to:
  /// **'Co-owner Request'**
  String get coOwnerRequest;

  /// No description provided for @byUser.
  ///
  /// In en, this message translates to:
  /// **'by {userName}'**
  String byUser(Object userName);

  /// No description provided for @byUserPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'userName'**
  String get byUserPlaceholder;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this request?'**
  String get cancelRequestConfirm;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @cancelRequestButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelRequestButton;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'🔄 Request cancelled'**
  String get requestCancelled;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'❌ Request rejected. Notification sent to the requester.'**
  String get requestRejected;

  /// No description provided for @errorAcceptingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error accepting request: {error}'**
  String errorAcceptingRequest(Object error);

  /// No description provided for @errorRejectingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error rejecting request: {error}'**
  String errorRejectingRequest(Object error);

  /// No description provided for @errorCancellingRequest.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling request: {error}'**
  String errorCancellingRequest(Object error);

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @notOwner.
  ///
  /// In en, this message translates to:
  /// **'Not Owner'**
  String get notOwner;

  /// No description provided for @cow.
  ///
  /// In en, this message translates to:
  /// **'Cow'**
  String get cow;

  /// No description provided for @horse.
  ///
  /// In en, this message translates to:
  /// **'Horse'**
  String get horse;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
