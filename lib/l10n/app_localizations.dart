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
  /// **'Mini Pet'**
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

  /// No description provided for @scheduledNotifications.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Notifications'**
  String get scheduledNotifications;

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
  /// **'Recognized Text:'**
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

  /// No description provided for @scheduledNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder notifications'**
  String get scheduledNotificationsDesc;

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
  /// **'Welcome to Mini Pet!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Track your pets, vaccinations, and more.'**
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
  /// **'Add your pet to start tracking.'**
  String get addPetDescription;

  /// No description provided for @vaccinationAndCare.
  ///
  /// In en, this message translates to:
  /// **'Vaccination & Care'**
  String get vaccinationAndCare;

  /// No description provided for @vaccinationAndCareDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your pet healthy with reminders.'**
  String get vaccinationAndCareDescription;

  /// No description provided for @profileAndHistory.
  ///
  /// In en, this message translates to:
  /// **'Profile & History'**
  String get profileAndHistory;

  /// No description provided for @profileAndHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'View your profile and pet history.'**
  String get profileAndHistoryDescription;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
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

  /// No description provided for @hunger.
  ///
  /// In en, this message translates to:
  /// **'Hunger'**
  String get hunger;

  /// No description provided for @feedingTimeSaved.
  ///
  /// In en, this message translates to:
  /// **'Feeding time saved!'**
  String get feedingTimeSaved;

  /// No description provided for @vaccinesToBeTaken.
  ///
  /// In en, this message translates to:
  /// **'Vaccines to be taken'**
  String get vaccinesToBeTaken;

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

  /// No description provided for @diaryChat.
  ///
  /// In en, this message translates to:
  /// **'Diary Chat'**
  String get diaryChat;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get errorOccurred;

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

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

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
  /// **'No vaccines found.'**
  String noVaccines(Object showDone);

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
  /// **'© 2024 Mini Pet'**
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

  /// No description provided for @nameMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters.'**
  String get nameMinLengthError;

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
