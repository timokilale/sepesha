import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
    Locale('sw')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sepesha'**
  String get appName;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete Conversation'**
  String get deleteConversation;

  /// No description provided for @areYouSureDeleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation with'**
  String get areYouSureDeleteConversation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @helloWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Hello, {userType}! Welcome back'**
  String helloWelcomeBack(Object userType);

  /// No description provided for @enterPhoneVerification.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number We\'ll send you a verification code'**
  String get enterPhoneVerification;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get searchCountry;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'DRIVER'**
  String get driver;

  /// No description provided for @driverDescription.
  ///
  /// In en, this message translates to:
  /// **'Login as a driver for easy gain request from customers and vendors'**
  String get driverDescription;

  /// No description provided for @vendorBusiness.
  ///
  /// In en, this message translates to:
  /// **'Vendor/Business'**
  String get vendorBusiness;

  /// No description provided for @vendorDescription.
  ///
  /// In en, this message translates to:
  /// **'Login as a vendor to manage your products and receive orders'**
  String get vendorDescription;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER'**
  String get customer;

  /// No description provided for @customerDescription.
  ///
  /// In en, this message translates to:
  /// **'Login as a customer to request deliveries and order products'**
  String get customerDescription;

  /// No description provided for @loginAsDriverOrVendor.
  ///
  /// In en, this message translates to:
  /// **'Login as Driver or Vendor'**
  String get loginAsDriverOrVendor;

  /// No description provided for @loginAsCustomerOrVendor.
  ///
  /// In en, this message translates to:
  /// **'Login as Customer or Vendor'**
  String get loginAsCustomerOrVendor;

  /// No description provided for @loginAsCustomerOrDriver.
  ///
  /// In en, this message translates to:
  /// **'Login as Customer or Driver'**
  String get loginAsCustomerOrDriver;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered? '**
  String get notRegistered;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @byContinuingYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our '**
  String get byContinuingYouAgree;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @youreOver18.
  ///
  /// In en, this message translates to:
  /// **'. You\'re over 18.'**
  String get youreOver18;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitRating.
  ///
  /// In en, this message translates to:
  /// **'Submit Rating'**
  String get submitRating;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @rateYourExperience.
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get rateYourExperience;

  /// No description provided for @errorSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get errorSigningOut;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'USER'**
  String get user;

  /// No description provided for @totalRides.
  ///
  /// In en, this message translates to:
  /// **'Total Rides'**
  String get totalRides;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @manageProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile details'**
  String get manageProfileDetails;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @managePaymentOptions.
  ///
  /// In en, this message translates to:
  /// **'Manage your payment options'**
  String get managePaymentOptions;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @viewConversations.
  ///
  /// In en, this message translates to:
  /// **'View your conversations'**
  String get viewConversations;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appPreferencesSettings.
  ///
  /// In en, this message translates to:
  /// **'App preferences and settings'**
  String get appPreferencesSettings;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @getHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appInformationVersion.
  ///
  /// In en, this message translates to:
  /// **'App information and version'**
  String get appInformationVersion;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signOutAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get signOutAccount;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @trySearchingWithDifferentKeywords.
  ///
  /// In en, this message translates to:
  /// **'Try searching with different keywords'**
  String get trySearchingWithDifferentKeywords;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear Search'**
  String get clearSearch;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @startNewConversationToBeginMessaging.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation to begin messaging'**
  String get startNewConversationToBeginMessaging;

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts...'**
  String get searchContacts;

  /// No description provided for @conversationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @allConversationsMarkedAsRead.
  ///
  /// In en, this message translates to:
  /// **'All conversations marked as read'**
  String get allConversationsMarkedAsRead;

  /// No description provided for @messageSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Message settings coming soon'**
  String get messageSettingsComingSoon;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// No description provided for @setPickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Set Pickup Location'**
  String get setPickupLocation;

  /// No description provided for @setDestination.
  ///
  /// In en, this message translates to:
  /// **'Set Destination'**
  String get setDestination;

  /// No description provided for @startTypingToSearch.
  ///
  /// In en, this message translates to:
  /// **'Start typing to search for locations'**
  String get startTypingToSearch;

  /// No description provided for @typeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get typeAtLeast2Characters;

  /// No description provided for @noLocationsFound.
  ///
  /// In en, this message translates to:
  /// **'No locations found'**
  String get noLocationsFound;

  /// No description provided for @driverFound.
  ///
  /// In en, this message translates to:
  /// **'Driver Found'**
  String get driverFound;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination:'**
  String get destination;

  /// No description provided for @isWaiting.
  ///
  /// In en, this message translates to:
  /// **'is waiting'**
  String get isWaiting;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications feature coming soon!'**
  String get notificationsComingSoon;

  /// No description provided for @filterTrips.
  ///
  /// In en, this message translates to:
  /// **'Filter trips feature coming soon!'**
  String get filterTrips;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'VENDOR'**
  String get vendor;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App information'**
  String get appInformation;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @manageWallet.
  ///
  /// In en, this message translates to:
  /// **'Manage your wallet'**
  String get manageWallet;

  /// No description provided for @yourDriverHasArrived.
  ///
  /// In en, this message translates to:
  /// **'Your driver has arrived'**
  String get yourDriverHasArrived;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @whatsappChat.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Chat'**
  String get whatsappChat;

  /// No description provided for @quickResponseViaWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Quick response via WhatsApp'**
  String get quickResponseViaWhatsapp;

  /// No description provided for @phoneCall.
  ///
  /// In en, this message translates to:
  /// **'Phone Call'**
  String get phoneCall;

  /// No description provided for @speakDirectlyWithOurTeam.
  ///
  /// In en, this message translates to:
  /// **'Speak directly with our team'**
  String get speakDirectlyWithOurTeam;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get allRightsReserved;

  /// No description provided for @saveTimeSaveMoneyAnd.
  ///
  /// In en, this message translates to:
  /// **'Save time, save money and'**
  String get saveTimeSaveMoneyAnd;

  /// No description provided for @safeRide.
  ///
  /// In en, this message translates to:
  /// **'Safe ride'**
  String get safeRide;

  /// No description provided for @useYourSmartphoneToOrder.
  ///
  /// In en, this message translates to:
  /// **'Use your smartphone to order a ride, get picked up by a nearby driver, and enjoy a low-cost trip to your destination.'**
  String get useYourSmartphoneToOrder;

  /// No description provided for @getConnectedWith.
  ///
  /// In en, this message translates to:
  /// **'Get connected with'**
  String get getConnectedWith;

  /// No description provided for @nearbyDrivers.
  ///
  /// In en, this message translates to:
  /// **'nearby drivers'**
  String get nearbyDrivers;

  /// No description provided for @quicklyMatchWithReliable.
  ///
  /// In en, this message translates to:
  /// **'Quickly match with reliable drivers around you for faster pickups and better service.'**
  String get quicklyMatchWithReliable;

  /// No description provided for @enjoyARideWith.
  ///
  /// In en, this message translates to:
  /// **'Enjoy a ride with'**
  String get enjoyARideWith;

  /// No description provided for @fullComfort.
  ///
  /// In en, this message translates to:
  /// **'full comfort'**
  String get fullComfort;

  /// No description provided for @relaxInWellMaintained.
  ///
  /// In en, this message translates to:
  /// **'Relax in well-maintained vehicles while your driver takes care of the road.'**
  String get relaxInWellMaintained;

  /// No description provided for @ridesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Rides completed'**
  String get ridesCompleted;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @vehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number'**
  String get vehicleNumber;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumber;

  /// No description provided for @locationAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Access Required'**
  String get locationAccessRequired;

  /// No description provided for @enableLocationPermissions.
  ///
  /// In en, this message translates to:
  /// **'Tap to enable location permissions to go online'**
  String get enableLocationPermissions;

  /// No description provided for @youAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are Online'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are Offline'**
  String get youAreOffline;

  /// No description provided for @waitingForRideRequests.
  ///
  /// In en, this message translates to:
  /// **'Waiting for ride requests...'**
  String get waitingForRideRequests;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup:'**
  String get pickup;

  /// No description provided for @startRide.
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get startRide;

  /// No description provided for @newRideRequest.
  ///
  /// In en, this message translates to:
  /// **'New Ride Request'**
  String get newRideRequest;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From:'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get to;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @dropoffLocation.
  ///
  /// In en, this message translates to:
  /// **'Dropoff Location'**
  String get dropoffLocation;

  /// No description provided for @refreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh Location'**
  String get refreshLocation;

  /// No description provided for @locationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Location updated:'**
  String get locationUpdated;

  /// No description provided for @couldNotGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get current location. Check permissions.'**
  String get couldNotGetLocation;

  /// No description provided for @areYouSureLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get areYouSureLogout;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location Services Disabled'**
  String get locationServicesDisabled;

  /// No description provided for @enableLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Please enable location services in your device settings to use this feature.'**
  String get enableLocationServices;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @enableLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to go online as a driver. Please enable location permission in app settings.'**
  String get enableLocationPermission;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Denied'**
  String get locationPermissionDenied;

  /// No description provided for @grantLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to track your position as a driver. Please grant location permission to continue.'**
  String get grantLocationPermission;

  /// No description provided for @locationPermissionsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are already enabled! You can go online.'**
  String get locationPermissionsEnabled;

  /// No description provided for @unableToGetLocationPermissions.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location permissions. Please check your device settings.'**
  String get unableToGetLocationPermissions;

  /// No description provided for @locationPermissionsGranted.
  ///
  /// In en, this message translates to:
  /// **'Location permissions granted! Getting your location...'**
  String get locationPermissionsGranted;

  /// No description provided for @locationFound.
  ///
  /// In en, this message translates to:
  /// **'Location found! Map updated to your current position.'**
  String get locationFound;

  /// No description provided for @errorRequestingLocationPermission.
  ///
  /// In en, this message translates to:
  /// **'Error requesting location permission:'**
  String get errorRequestingLocationPermission;

  /// No description provided for @driverEmail.
  ///
  /// In en, this message translates to:
  /// **'driver@sepesha.com'**
  String get driverEmail;

  /// No description provided for @driverPhone.
  ///
  /// In en, this message translates to:
  /// **'+255000000000'**
  String get driverPhone;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @driverProfile.
  ///
  /// In en, this message translates to:
  /// **'Driver Profile'**
  String get driverProfile;

  /// No description provided for @manageDriverProfile.
  ///
  /// In en, this message translates to:
  /// **'Manage your driver profile'**
  String get manageDriverProfile;

  /// No description provided for @viewWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'View wallet balance and transactions'**
  String get viewWalletBalance;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @paymentPreference.
  ///
  /// In en, this message translates to:
  /// **'Payment Preference'**
  String get paymentPreference;

  /// No description provided for @rideHistory.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get rideHistory;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @driverNotAssigned.
  ///
  /// In en, this message translates to:
  /// **'Driver not assigned'**
  String get driverNotAssigned;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get locationUnavailable;

  /// No description provided for @calculatingArrival.
  ///
  /// In en, this message translates to:
  /// **'Calculating arrival...'**
  String get calculatingArrival;

  /// No description provided for @arrivingNow.
  ///
  /// In en, this message translates to:
  /// **'Arriving now'**
  String get arrivingNow;

  /// No description provided for @arrivesInMinute.
  ///
  /// In en, this message translates to:
  /// **'Arrives in 1 minute'**
  String get arrivesInMinute;

  /// No description provided for @arrivesInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Arrives in minutes'**
  String get arrivesInMinutes;

  /// No description provided for @noActiveRides.
  ///
  /// In en, this message translates to:
  /// **'No active rides'**
  String get noActiveRides;

  /// No description provided for @noCompletedRides.
  ///
  /// In en, this message translates to:
  /// **'No completed rides'**
  String get noCompletedRides;

  /// No description provided for @noCanceledRides.
  ///
  /// In en, this message translates to:
  /// **'No canceled rides'**
  String get noCanceledRides;

  /// No description provided for @unknownDriver.
  ///
  /// In en, this message translates to:
  /// **'Unknown Driver'**
  String get unknownDriver;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'COST'**
  String get cost;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get date;

  /// No description provided for @estimatedTripTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated trip time: '**
  String get estimatedTripTime;

  /// No description provided for @contactDriver.
  ///
  /// In en, this message translates to:
  /// **'Contact Driver'**
  String get contactDriver;

  /// No description provided for @cancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get cancelRide;

  /// No description provided for @rateThisRide.
  ///
  /// In en, this message translates to:
  /// **'Rate This Ride'**
  String get rateThisRide;

  /// No description provided for @bookAgain.
  ///
  /// In en, this message translates to:
  /// **'Book Again'**
  String get bookAgain;

  /// No description provided for @tripDuration.
  ///
  /// In en, this message translates to:
  /// **'Trip duration: '**
  String get tripDuration;

  /// No description provided for @chooseYourRide.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Ride'**
  String get chooseYourRide;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @twoWheeler.
  ///
  /// In en, this message translates to:
  /// **'2 Wheeler'**
  String get twoWheeler;

  /// No description provided for @fourWheeler.
  ///
  /// In en, this message translates to:
  /// **'4 Wheeler'**
  String get fourWheeler;

  /// No description provided for @addLuggageSpace.
  ///
  /// In en, this message translates to:
  /// **'Add Luggage Space'**
  String get addLuggageSpace;

  /// No description provided for @haveAPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Have a promo code?'**
  String get haveAPromoCode;

  /// No description provided for @enterPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Enter promo code'**
  String get enterPromoCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @bodaboda.
  ///
  /// In en, this message translates to:
  /// **'Bodaboda'**
  String get bodaboda;

  /// No description provided for @bajaj.
  ///
  /// In en, this message translates to:
  /// **'Bajaj'**
  String get bajaj;

  /// No description provided for @guta.
  ///
  /// In en, this message translates to:
  /// **'Guta'**
  String get guta;

  /// No description provided for @carry.
  ///
  /// In en, this message translates to:
  /// **'Carry'**
  String get carry;

  /// No description provided for @townace.
  ///
  /// In en, this message translates to:
  /// **'Townace'**
  String get townace;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity: '**
  String get capacity;

  /// No description provided for @lookingForDriver.
  ///
  /// In en, this message translates to:
  /// **'Looking for a driver'**
  String get lookingForDriver;

  /// No description provided for @findingBestDriver.
  ///
  /// In en, this message translates to:
  /// **'We\'re finding the best driver for you'**
  String get findingBestDriver;

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get tripInProgress;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @endTrip.
  ///
  /// In en, this message translates to:
  /// **'End Trip'**
  String get endTrip;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete Trip'**
  String get completeTrip;

  /// No description provided for @areYouSureEndTrip.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to end this trip?'**
  String get areYouSureEndTrip;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle Name (Optional)'**
  String get middleName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @phoneNumberMinDigits.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 9 digits'**
  String get phoneNumberMinDigits;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select Region'**
  String get selectRegion;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @errorSavingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error saving profile:'**
  String get errorSavingProfile;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @failedToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedToLoadReviews;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noReviewsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No reviews available'**
  String get noReviewsAvailable;

  /// No description provided for @basedOnCustomerFeedback.
  ///
  /// In en, this message translates to:
  /// **'Based on customer feedback'**
  String get basedOnCustomerFeedback;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

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

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @findingDriver.
  ///
  /// In en, this message translates to:
  /// **'Finding a driver...'**
  String get findingDriver;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @minutesToDelivery.
  ///
  /// In en, this message translates to:
  /// **'Minutes to delivery'**
  String get minutesToDelivery;

  /// No description provided for @callRecipient.
  ///
  /// In en, this message translates to:
  /// **'Call Recipient'**
  String get callRecipient;

  /// No description provided for @startDropOffProcess.
  ///
  /// In en, this message translates to:
  /// **'Start Drop off process'**
  String get startDropOffProcess;

  /// No description provided for @deliveryCompleted.
  ///
  /// In en, this message translates to:
  /// **'Delivery Completed!'**
  String get deliveryCompleted;

  /// No description provided for @pleaseRateDriver.
  ///
  /// In en, this message translates to:
  /// **'Please rate your driver...'**
  String get pleaseRateDriver;

  /// No description provided for @cannotRateDriver.
  ///
  /// In en, this message translates to:
  /// **'Cannot rate: Driver information not available'**
  String get cannotRateDriver;

  /// No description provided for @deliveryInProgress.
  ///
  /// In en, this message translates to:
  /// **'Delivery in progress'**
  String get deliveryInProgress;

  /// No description provided for @driverName.
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driverName;

  /// No description provided for @driverStats.
  ///
  /// In en, this message translates to:
  /// **'Driver Stats'**
  String get driverStats;

  /// No description provided for @selectLuggageSize.
  ///
  /// In en, this message translates to:
  /// **'Select Luggage Size'**
  String get selectLuggageSize;

  /// No description provided for @personalItem.
  ///
  /// In en, this message translates to:
  /// **'Personal Item'**
  String get personalItem;

  /// No description provided for @internationalCarryOn.
  ///
  /// In en, this message translates to:
  /// **'International carry on'**
  String get internationalCarryOn;

  /// No description provided for @domesticCarryOn.
  ///
  /// In en, this message translates to:
  /// **'Domestic Carry On'**
  String get domesticCarryOn;

  /// No description provided for @smallChecked.
  ///
  /// In en, this message translates to:
  /// **'Small Checked'**
  String get smallChecked;

  /// No description provided for @mediumChecked.
  ///
  /// In en, this message translates to:
  /// **'Medium Checked'**
  String get mediumChecked;

  /// No description provided for @takeProofOfPickupParcel.
  ///
  /// In en, this message translates to:
  /// **'Take proof of Pickup Parcel'**
  String get takeProofOfPickupParcel;

  /// No description provided for @requestARide.
  ///
  /// In en, this message translates to:
  /// **'Request a Ride'**
  String get requestARide;

  /// No description provided for @rideAmount.
  ///
  /// In en, this message translates to:
  /// **'Ride Amount:'**
  String get rideAmount;

  /// No description provided for @additionalCost.
  ///
  /// In en, this message translates to:
  /// **'Additional Cost:'**
  String get additionalCost;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get total;

  /// No description provided for @kgs.
  ///
  /// In en, this message translates to:
  /// **'kgs'**
  String get kgs;

  /// No description provided for @yourTravelTakes.
  ///
  /// In en, this message translates to:
  /// **'Your travel takes minutes'**
  String get yourTravelTakes;

  /// No description provided for @findingNearestRide.
  ///
  /// In en, this message translates to:
  /// **'Finding the nearest Ride...'**
  String get findingNearestRide;

  /// No description provided for @rideway.
  ///
  /// In en, this message translates to:
  /// **'Rideway'**
  String get rideway;

  /// No description provided for @affordableRides.
  ///
  /// In en, this message translates to:
  /// **'Affordable rides, all to yourself'**
  String get affordableRides;

  /// No description provided for @ridewaySuv.
  ///
  /// In en, this message translates to:
  /// **'Rideway SUV'**
  String get ridewaySuv;

  /// No description provided for @luxuryRides.
  ///
  /// In en, this message translates to:
  /// **'Luxury rides'**
  String get luxuryRides;

  /// No description provided for @luggage.
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get luggage;

  /// No description provided for @discountCode.
  ///
  /// In en, this message translates to:
  /// **'Discount code'**
  String get discountCode;

  /// No description provided for @enterDiscountCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Discount Code'**
  String get enterDiscountCode;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get enterCode;

  /// No description provided for @aboutSepesha.
  ///
  /// In en, this message translates to:
  /// **'About Sepesha'**
  String get aboutSepesha;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @supportEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: support@sepesha.com'**
  String get supportEmail;

  /// No description provided for @supportPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: +255 123 456 789'**
  String get supportPhone;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website: www.sepesha.com'**
  String get website;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address:\nLorem ipsum street, 123\nDar es Salaam, Tanzania'**
  String get address;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @endUserLicenseAgreement.
  ///
  /// In en, this message translates to:
  /// **'End User License Agreement'**
  String get endUserLicenseAgreement;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Sepesha. All rights reserved.'**
  String get copyright;

  /// No description provided for @failedToLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get failedToLoadMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation by sending a message'**
  String get startConversation;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @lastSeenRecently.
  ///
  /// In en, this message translates to:
  /// **'Last seen recently'**
  String get lastSeenRecently;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @areYouSureClearChat.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear this chat? This action cannot be undone.'**
  String get areYouSureClearChat;

  /// No description provided for @areYouSureBlockUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user?'**
  String get areYouSureBlockUser;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @messageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopied;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @replyFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Reply functionality coming soon'**
  String get replyFunctionalityComingSoon;

  /// No description provided for @voiceCallFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Voice call feature coming soon'**
  String get voiceCallFeatureComingSoon;

  /// No description provided for @videoCallFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Video call feature coming soon'**
  String get videoCallFeatureComingSoon;

  /// No description provided for @profileViewComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Profile view coming soon'**
  String get profileViewComingSoon;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared'**
  String get chatCleared;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked'**
  String get userBlocked;

  /// No description provided for @saveImageComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Save image coming soon'**
  String get saveImageComingSoon;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @failedToShareLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to share location: '**
  String get failedToShareLocation;

  /// No description provided for @userType.
  ///
  /// In en, this message translates to:
  /// **'User Type'**
  String get userType;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @unverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverified;

  /// No description provided for @walletBalanceTzs.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance (TZS)'**
  String get walletBalanceTzs;

  /// No description provided for @walletBalanceUsd.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance (USD)'**
  String get walletBalanceUsd;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @noProfileDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No profile data available'**
  String get noProfileDataAvailable;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @loadingPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Loading payment methods...'**
  String get loadingPaymentMethods;

  /// No description provided for @paymentMethodUpdated.
  ///
  /// In en, this message translates to:
  /// **'Payment method updated'**
  String get paymentMethodUpdated;

  /// No description provided for @failedToUpdatePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Failed to update payment method'**
  String get failedToUpdatePaymentMethod;

  /// No description provided for @walletBalanceDetails.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance Details'**
  String get walletBalanceDetails;

  /// No description provided for @tzsBalance.
  ///
  /// In en, this message translates to:
  /// **'TZS Balance'**
  String get tzsBalance;

  /// No description provided for @usdBalance.
  ///
  /// In en, this message translates to:
  /// **'USD Balance'**
  String get usdBalance;

  /// No description provided for @walletReadyForPayments.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is ready for payments'**
  String get walletReadyForPayments;

  /// No description provided for @addFundsToWallet.
  ///
  /// In en, this message translates to:
  /// **'Add funds to your wallet to use this payment method'**
  String get addFundsToWallet;

  /// No description provided for @unableToLoadWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Unable to load wallet balance'**
  String get unableToLoadWalletBalance;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @searchRide.
  ///
  /// In en, this message translates to:
  /// **'Search Ride'**
  String get searchRide;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// No description provided for @findRide.
  ///
  /// In en, this message translates to:
  /// **'Find Ride'**
  String get findRide;

  /// No description provided for @accountStatistics.
  ///
  /// In en, this message translates to:
  /// **'Account Statistics'**
  String get accountStatistics;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get averageRating;

  /// No description provided for @walletTzs.
  ///
  /// In en, this message translates to:
  /// **'Wallet (TZS)'**
  String get walletTzs;

  /// No description provided for @walletUsd.
  ///
  /// In en, this message translates to:
  /// **'Wallet (USD)'**
  String get walletUsd;

  /// No description provided for @preferredPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Preferred Payment Method'**
  String get preferredPaymentMethod;

  /// No description provided for @verifiedAccount.
  ///
  /// In en, this message translates to:
  /// **'Verified Account'**
  String get verifiedAccount;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get pendingVerification;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'sw': return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
