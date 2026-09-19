import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_te.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Farm-to-Market'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @farmer.
  ///
  /// In en, this message translates to:
  /// **'Farmer'**
  String get farmer;

  /// No description provided for @retailer.
  ///
  /// In en, this message translates to:
  /// **'Retailer'**
  String get retailer;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @farmerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Farmer Dashboard'**
  String get farmerDashboard;

  /// No description provided for @welcomeFarmer.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Farmer!'**
  String get welcomeFarmer;

  /// No description provided for @welcomeFarmerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Intelligent crop recommendation and market matching will appear here.'**
  String get welcomeFarmerSubtitle;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'Profile Error'**
  String get profileError;

  /// No description provided for @profileErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your user profile and role from the database. Please ensure the Supabase profiles table is configured.'**
  String get profileErrorMessage;

  /// No description provided for @returnToLogin.
  ///
  /// In en, this message translates to:
  /// **'Return to Login'**
  String get returnToLogin;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Intelligent Decision & Market Linkage'**
  String get appSubtitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registeringAs.
  ///
  /// In en, this message translates to:
  /// **'Registering as (Role)'**
  String get registeringAs;

  /// No description provided for @verifyingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Verifying permissions...'**
  String get verifyingPermissions;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @farmerInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer Input'**
  String get farmerInputTitle;

  /// No description provided for @farmerInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your farm details to get intelligent market recommendations'**
  String get farmerInputSubtitle;

  /// No description provided for @startCropRecommendation.
  ///
  /// In en, this message translates to:
  /// **'New Farm Recommendation'**
  String get startCropRecommendation;

  /// No description provided for @stepCrop.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get stepCrop;

  /// No description provided for @stepArea.
  ///
  /// In en, this message translates to:
  /// **'Farm Area'**
  String get stepArea;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepLocation;

  /// No description provided for @stepEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get stepEnvironment;

  /// No description provided for @cropSelection.
  ///
  /// In en, this message translates to:
  /// **'Select Crop'**
  String get cropSelection;

  /// No description provided for @cropSelectionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose the crop you are harvesting or planning to sell'**
  String get cropSelectionPrompt;

  /// No description provided for @rice.
  ///
  /// In en, this message translates to:
  /// **'Rice'**
  String get rice;

  /// No description provided for @maize.
  ///
  /// In en, this message translates to:
  /// **'Maize'**
  String get maize;

  /// No description provided for @chickpea.
  ///
  /// In en, this message translates to:
  /// **'Chickpea'**
  String get chickpea;

  /// No description provided for @cotton.
  ///
  /// In en, this message translates to:
  /// **'Cotton'**
  String get cotton;

  /// No description provided for @farmArea.
  ///
  /// In en, this message translates to:
  /// **'Farm Area'**
  String get farmArea;

  /// No description provided for @farmAreaPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the total cultivated area'**
  String get farmAreaPrompt;

  /// No description provided for @areaInHectares.
  ///
  /// In en, this message translates to:
  /// **'Cultivated Area (ha)'**
  String get areaInHectares;

  /// No description provided for @hectares.
  ///
  /// In en, this message translates to:
  /// **'hectares'**
  String get hectares;

  /// No description provided for @areaHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5.0 hectares'**
  String get areaHelper;

  /// No description provided for @farmLocation.
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farmLocation;

  /// No description provided for @farmLocationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Specify where your farm is located'**
  String get farmLocationPrompt;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select State'**
  String get selectState;

  /// No description provided for @enterDistrict.
  ///
  /// In en, this message translates to:
  /// **'Enter District Name'**
  String get enterDistrict;

  /// No description provided for @districtHelper.
  ///
  /// In en, this message translates to:
  /// **'e.g., Guntur, Krishna'**
  String get districtHelper;

  /// No description provided for @farmEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Farming & Environment'**
  String get farmEnvironment;

  /// No description provided for @farmEnvironmentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter soil and seasonal weather estimates for your farm'**
  String get farmEnvironmentPrompt;

  /// No description provided for @advancedEnvironmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Advanced Environmental Data'**
  String get advancedEnvironmentTitle;

  /// No description provided for @environmentalAutoFetchNote.
  ///
  /// In en, this message translates to:
  /// **'Note: In future updates, these soil nutrients and weather values can be automatically filled using your farm\'s location.'**
  String get environmentalAutoFetchNote;

  /// No description provided for @soilNutrients.
  ///
  /// In en, this message translates to:
  /// **'Soil Nutrients (NPK)'**
  String get soilNutrients;

  /// No description provided for @weatherClimate.
  ///
  /// In en, this message translates to:
  /// **'Weather & Climate'**
  String get weatherClimate;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Harvest Year'**
  String get year;

  /// No description provided for @nitrogen.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N) Requirement'**
  String get nitrogen;

  /// No description provided for @phosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P) Requirement'**
  String get phosphorus;

  /// No description provided for @potassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K) Requirement'**
  String get potassium;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Average Temperature'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Relative Humidity'**
  String get humidity;

  /// No description provided for @soilPh.
  ///
  /// In en, this message translates to:
  /// **'Soil pH Level'**
  String get soilPh;

  /// No description provided for @rainfall.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Rainfall'**
  String get rainfall;

  /// No description provided for @windSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get windSpeed;

  /// No description provided for @solarRadiation.
  ///
  /// In en, this message translates to:
  /// **'Solar Radiation'**
  String get solarRadiation;

  /// No description provided for @kgPerHa.
  ///
  /// In en, this message translates to:
  /// **'kg/ha'**
  String get kgPerHa;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsius;

  /// No description provided for @percent.
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// No description provided for @mm.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get mm;

  /// No description provided for @mPerS.
  ///
  /// In en, this message translates to:
  /// **'m/s'**
  String get mPerS;

  /// No description provided for @mjPerM2Day.
  ///
  /// In en, this message translates to:
  /// **'MJ/m²/day'**
  String get mjPerM2Day;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @inputsCollectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Farmer inputs collected successfully! Ready for recommendation.'**
  String get inputsCollectedSuccess;

  /// No description provided for @pleaseSelectCrop.
  ///
  /// In en, this message translates to:
  /// **'Please select a crop'**
  String get pleaseSelectCrop;

  /// No description provided for @pleaseEnterValidArea.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid area greater than 0 ha'**
  String get pleaseEnterValidArea;

  /// No description provided for @pleaseSelectState.
  ///
  /// In en, this message translates to:
  /// **'Please select your state'**
  String get pleaseSelectState;

  /// No description provided for @pleaseEnterDistrict.
  ///
  /// In en, this message translates to:
  /// **'Please enter your district'**
  String get pleaseEnterDistrict;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @pleaseEnterPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Value must be 0 or greater'**
  String get pleaseEnterPositiveNumber;

  /// No description provided for @humidityRangeError.
  ///
  /// In en, this message translates to:
  /// **'Humidity must be between 0% and 100%'**
  String get humidityRangeError;

  /// No description provided for @phRangeError.
  ///
  /// In en, this message translates to:
  /// **'pH must be between 0 and 14'**
  String get phRangeError;

  /// No description provided for @useMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Use My Location'**
  String get useMyLocation;

  /// No description provided for @detectingLocation.
  ///
  /// In en, this message translates to:
  /// **'Detecting location...'**
  String get detectingLocation;

  /// No description provided for @locationDetected.
  ///
  /// In en, this message translates to:
  /// **'Location Detected'**
  String get locationDetected;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Detected Coordinates'**
  String get locationDetails;

  /// No description provided for @farmLocationCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Farm Location'**
  String get farmLocationCardTitle;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @gpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS Accuracy'**
  String get gpsAccuracy;

  /// No description provided for @findingLocationDetails.
  ///
  /// In en, this message translates to:
  /// **'Finding your location details...'**
  String get findingLocationDetails;

  /// No description provided for @addressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Address unavailable'**
  String get addressUnavailable;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Please allow location access to use GPS.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is permanently denied. Please enable it in device settings.'**
  String get locationPermissionRequired;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are turned off. Please turn on GPS on your device.'**
  String get locationServicesDisabled;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Could not fetch location in time. Please try again or ensure good GPS signal.'**
  String get locationTimeout;

  /// No description provided for @locationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve location. Please check settings and try again.'**
  String get locationErrorGeneric;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @optionalGpsNote.
  ///
  /// In en, this message translates to:
  /// **'GPS coordinates are optional. You can still proceed with State and District.'**
  String get optionalGpsNote;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @newRecommendation.
  ///
  /// In en, this message translates to:
  /// **'New Recommendation'**
  String get newRecommendation;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @transportTracking.
  ///
  /// In en, this message translates to:
  /// **'Transport Tracking'**
  String get transportTracking;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available in an upcoming update.'**
  String get featureComingSoon;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed. Please check your connection and try again.'**
  String get signOutFailed;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Navigation Menu'**
  String get menuTooltip;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @newFarmRecommendation.
  ///
  /// In en, this message translates to:
  /// **'New Farm Recommendation'**
  String get newFarmRecommendation;

  /// No description provided for @findBestMarketSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find the best market for your vegetables'**
  String get findBestMarketSubtitle;

  /// No description provided for @stepVegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetable'**
  String get stepVegetable;

  /// No description provided for @selectVegetable.
  ///
  /// In en, this message translates to:
  /// **'Select Vegetable'**
  String get selectVegetable;

  /// No description provided for @selectVegetablePrompt.
  ///
  /// In en, this message translates to:
  /// **'Choose the vegetable you are harvesting or planning to sell'**
  String get selectVegetablePrompt;

  /// No description provided for @pleaseSelectVegetable.
  ///
  /// In en, this message translates to:
  /// **'Please select a vegetable'**
  String get pleaseSelectVegetable;

  /// No description provided for @stepDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get stepDetails;

  /// No description provided for @stepDetailsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Environmental and soil parameters'**
  String get stepDetailsPrompt;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @vegTomato.
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get vegTomato;

  /// No description provided for @vegOnion.
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get vegOnion;

  /// No description provided for @vegPotato.
  ///
  /// In en, this message translates to:
  /// **'Potato'**
  String get vegPotato;

  /// No description provided for @vegBrinjal.
  ///
  /// In en, this message translates to:
  /// **'Brinjal'**
  String get vegBrinjal;

  /// No description provided for @vegBhindi.
  ///
  /// In en, this message translates to:
  /// **'Bhindi'**
  String get vegBhindi;

  /// No description provided for @vegBottleGourd.
  ///
  /// In en, this message translates to:
  /// **'Bottle Gourd'**
  String get vegBottleGourd;

  /// No description provided for @vegBitterGourd.
  ///
  /// In en, this message translates to:
  /// **'Bitter Gourd'**
  String get vegBitterGourd;

  /// No description provided for @vegRidgeGourd.
  ///
  /// In en, this message translates to:
  /// **'Ridge Gourd'**
  String get vegRidgeGourd;

  /// No description provided for @vegSnakeGourd.
  ///
  /// In en, this message translates to:
  /// **'Snake Gourd'**
  String get vegSnakeGourd;

  /// No description provided for @vegCabbage.
  ///
  /// In en, this message translates to:
  /// **'Cabbage'**
  String get vegCabbage;

  /// No description provided for @vegCauliflower.
  ///
  /// In en, this message translates to:
  /// **'Cauliflower'**
  String get vegCauliflower;

  /// No description provided for @vegCarrot.
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get vegCarrot;

  /// No description provided for @vegBeans.
  ///
  /// In en, this message translates to:
  /// **'Beans'**
  String get vegBeans;

  /// No description provided for @vegGreenPeas.
  ///
  /// In en, this message translates to:
  /// **'Green Peas'**
  String get vegGreenPeas;

  /// No description provided for @vegSpinach.
  ///
  /// In en, this message translates to:
  /// **'Spinach'**
  String get vegSpinach;

  /// No description provided for @vegCapsicum.
  ///
  /// In en, this message translates to:
  /// **'Capsicum'**
  String get vegCapsicum;

  /// No description provided for @vegGreenChilli.
  ///
  /// In en, this message translates to:
  /// **'Green Chilli'**
  String get vegGreenChilli;

  /// No description provided for @farmWeather.
  ///
  /// In en, this message translates to:
  /// **'Farm Weather'**
  String get farmWeather;

  /// No description provided for @weatherTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get weatherTemperature;

  /// No description provided for @weatherHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get weatherHumidity;

  /// No description provided for @weatherRainfall.
  ///
  /// In en, this message translates to:
  /// **'Rainfall'**
  String get weatherRainfall;

  /// No description provided for @weatherWindSpeed.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get weatherWindSpeed;

  /// No description provided for @gettingWeather.
  ///
  /// In en, this message translates to:
  /// **'Getting weather...'**
  String get gettingWeather;

  /// No description provided for @weatherUpdated.
  ///
  /// In en, this message translates to:
  /// **'Weather updated'**
  String get weatherUpdated;

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @weatherAvailableAfterLocation.
  ///
  /// In en, this message translates to:
  /// **'Weather will be available after location detection'**
  String get weatherAvailableAfterLocation;

  /// No description provided for @kmh.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// No description provided for @farmToMarketRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Farm-to-Market Recommendation'**
  String get farmToMarketRecommendation;

  /// No description provided for @recommendedSellingOption.
  ///
  /// In en, this message translates to:
  /// **'Recommended selling option'**
  String get recommendedSellingOption;

  /// No description provided for @analyzingFarmDetails.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your farm details'**
  String get analyzingFarmDetails;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis Complete'**
  String get analysisComplete;

  /// No description provided for @recommendedMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Market'**
  String get recommendedMarketTitle;

  /// No description provided for @marketNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Market Name'**
  String get marketNameLabel;

  /// No description provided for @buyerLabel.
  ///
  /// In en, this message translates to:
  /// **'Buyer'**
  String get buyerLabel;

  /// No description provided for @expectedPrice.
  ///
  /// In en, this message translates to:
  /// **'Expected Price'**
  String get expectedPrice;

  /// No description provided for @expectedNetRevenue.
  ///
  /// In en, this message translates to:
  /// **'Expected Net Revenue'**
  String get expectedNetRevenue;

  /// No description provided for @expectedSupply.
  ///
  /// In en, this message translates to:
  /// **'Expected Supply'**
  String get expectedSupply;

  /// No description provided for @tonnes.
  ///
  /// In en, this message translates to:
  /// **'tonnes'**
  String get tonnes;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @cropLabel.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get cropLabel;

  /// No description provided for @farmAreaLabel.
  ///
  /// In en, this message translates to:
  /// **'Farm Area'**
  String get farmAreaLabel;

  /// No description provided for @marketComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Comparison'**
  String get marketComparisonTitle;

  /// No description provided for @saleableQuantity.
  ///
  /// In en, this message translates to:
  /// **'Saleable Quantity'**
  String get saleableQuantity;

  /// No description provided for @transportCost.
  ///
  /// In en, this message translates to:
  /// **'Transport Cost'**
  String get transportCost;

  /// No description provided for @spoilageLabel.
  ///
  /// In en, this message translates to:
  /// **'Spoilage'**
  String get spoilageLabel;

  /// No description provided for @demandStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Demand Status'**
  String get demandStatusLabel;

  /// No description provided for @lowDemand.
  ///
  /// In en, this message translates to:
  /// **'Low Demand'**
  String get lowDemand;

  /// No description provided for @mediumDemand.
  ///
  /// In en, this message translates to:
  /// **'Medium Demand'**
  String get mediumDemand;

  /// No description provided for @highDemand.
  ///
  /// In en, this message translates to:
  /// **'High Demand'**
  String get highDemand;

  /// No description provided for @whyThisRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this recommendation?'**
  String get whyThisRecommendationTitle;

  /// No description provided for @recommendationReasonDefault.
  ///
  /// In en, this message translates to:
  /// **'Highest feasible net expected revenue after transport cost, while accounting for spoilage and buyer capacity.'**
  String get recommendationReasonDefault;

  /// No description provided for @transportRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Transport Route'**
  String get transportRouteTitle;

  /// No description provided for @farmOrigin.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get farmOrigin;

  /// No description provided for @travelTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get travelTimeLabel;

  /// No description provided for @freshnessSpoilageTitle.
  ///
  /// In en, this message translates to:
  /// **'Freshness & Spoilage'**
  String get freshnessSpoilageTitle;

  /// No description provided for @freshnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Freshness'**
  String get freshnessLabel;

  /// No description provided for @rottenLabel.
  ///
  /// In en, this message translates to:
  /// **'Rotten'**
  String get rottenLabel;

  /// No description provided for @spoilageRisk.
  ///
  /// In en, this message translates to:
  /// **'Spoilage Risk'**
  String get spoilageRisk;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get lowRisk;

  /// No description provided for @spoiledQuantity.
  ///
  /// In en, this message translates to:
  /// **'Spoiled Quantity'**
  String get spoiledQuantity;

  /// No description provided for @priceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Analysis'**
  String get priceDetailsTitle;

  /// No description provided for @currentMarketPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Market Price'**
  String get currentMarketPrice;

  /// No description provided for @predictedFuturePrice.
  ///
  /// In en, this message translates to:
  /// **'Predicted Future Price'**
  String get predictedFuturePrice;

  /// No description provided for @currentModalPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Modal Price'**
  String get currentModalPrice;

  /// No description provided for @predictedFutureModalPrice.
  ///
  /// In en, this message translates to:
  /// **'Predicted Future Modal Price'**
  String get predictedFutureModalPrice;

  /// No description provided for @perKg.
  ///
  /// In en, this message translates to:
  /// **'per kg'**
  String get perKg;

  /// No description provided for @perQuintal.
  ///
  /// In en, this message translates to:
  /// **'quintal'**
  String get perQuintal;

  /// No description provided for @demandBuyerCapacityTitle.
  ///
  /// In en, this message translates to:
  /// **'Demand & Buyer Capacity'**
  String get demandBuyerCapacityTitle;

  /// No description provided for @demandLabel.
  ///
  /// In en, this message translates to:
  /// **'Demand'**
  String get demandLabel;

  /// No description provided for @buyerCapacity.
  ///
  /// In en, this message translates to:
  /// **'Buyer Capacity'**
  String get buyerCapacity;

  /// No description provided for @availableCapacity.
  ///
  /// In en, this message translates to:
  /// **'Available Capacity'**
  String get availableCapacity;

  /// No description provided for @demandCoverage.
  ///
  /// In en, this message translates to:
  /// **'Demand Coverage'**
  String get demandCoverage;

  /// No description provided for @capacityStatus.
  ///
  /// In en, this message translates to:
  /// **'Capacity Status'**
  String get capacityStatus;

  /// No description provided for @capacityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get capacityAvailable;

  /// No description provided for @viewMarketDetails.
  ///
  /// In en, this message translates to:
  /// **'View Market Details'**
  String get viewMarketDetails;

  /// No description provided for @startNewRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Start New Recommendation'**
  String get startNewRecommendation;

  /// No description provided for @marketDetailsNote.
  ///
  /// In en, this message translates to:
  /// **'Detailed market trade and logistics view.'**
  String get marketDetailsNote;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
