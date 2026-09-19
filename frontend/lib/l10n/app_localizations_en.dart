// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Farm-to-Market';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get farmer => 'Farmer';

  @override
  String get retailer => 'Retailer';

  @override
  String get createAccountButton => 'Create Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get farmerDashboard => 'Farmer Dashboard';

  @override
  String get welcomeFarmer => 'Welcome, Farmer!';

  @override
  String get welcomeFarmerSubtitle =>
      'Intelligent crop recommendation and market matching will appear here.';

  @override
  String get profileError => 'Profile Error';

  @override
  String get profileErrorMessage =>
      'Unable to load your user profile and role from the database. Please ensure the Supabase profiles table is configured.';

  @override
  String get returnToLogin => 'Return to Login';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get appSubtitle => 'Intelligent Decision & Market Linkage';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get register => 'Register';

  @override
  String get registeringAs => 'Registering as (Role)';

  @override
  String get verifyingPermissions => 'Verifying permissions...';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get farmerInputTitle => 'Farmer Input';

  @override
  String get farmerInputSubtitle =>
      'Enter your farm details to get intelligent market recommendations';

  @override
  String get startCropRecommendation => 'New Farm Recommendation';

  @override
  String get stepCrop => 'Crop';

  @override
  String get stepArea => 'Farm Area';

  @override
  String get stepLocation => 'Location';

  @override
  String get stepEnvironment => 'Environment';

  @override
  String get cropSelection => 'Select Crop';

  @override
  String get cropSelectionPrompt =>
      'Choose the crop you are harvesting or planning to sell';

  @override
  String get rice => 'Rice';

  @override
  String get maize => 'Maize';

  @override
  String get chickpea => 'Chickpea';

  @override
  String get cotton => 'Cotton';

  @override
  String get farmArea => 'Farm Area';

  @override
  String get farmAreaPrompt => 'Enter the total cultivated area';

  @override
  String get areaInHectares => 'Cultivated Area (ha)';

  @override
  String get hectares => 'hectares';

  @override
  String get areaHelper => 'e.g., 5.0 hectares';

  @override
  String get farmLocation => 'Farm Location';

  @override
  String get farmLocationPrompt => 'Specify where your farm is located';

  @override
  String get state => 'State';

  @override
  String get district => 'District';

  @override
  String get selectState => 'Select State';

  @override
  String get enterDistrict => 'Enter District Name';

  @override
  String get districtHelper => 'e.g., Guntur, Krishna';

  @override
  String get farmEnvironment => 'Farming & Environment';

  @override
  String get farmEnvironmentPrompt =>
      'Enter soil and seasonal weather estimates for your farm';

  @override
  String get advancedEnvironmentTitle => 'Advanced Environmental Data';

  @override
  String get environmentalAutoFetchNote =>
      'Note: In future updates, these soil nutrients and weather values can be automatically filled using your farm\'s location.';

  @override
  String get soilNutrients => 'Soil Nutrients (NPK)';

  @override
  String get weatherClimate => 'Weather & Climate';

  @override
  String get year => 'Harvest Year';

  @override
  String get nitrogen => 'Nitrogen (N) Requirement';

  @override
  String get phosphorus => 'Phosphorus (P) Requirement';

  @override
  String get potassium => 'Potassium (K) Requirement';

  @override
  String get temperature => 'Average Temperature';

  @override
  String get humidity => 'Relative Humidity';

  @override
  String get soilPh => 'Soil pH Level';

  @override
  String get rainfall => 'Seasonal Rainfall';

  @override
  String get windSpeed => 'Wind Speed';

  @override
  String get solarRadiation => 'Solar Radiation';

  @override
  String get kgPerHa => 'kg/ha';

  @override
  String get celsius => '°C';

  @override
  String get percent => '%';

  @override
  String get mm => 'mm';

  @override
  String get mPerS => 'm/s';

  @override
  String get mjPerM2Day => 'MJ/m²/day';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get continueButton => 'Continue';

  @override
  String get inputsCollectedSuccess =>
      'Farmer inputs collected successfully! Ready for recommendation.';

  @override
  String get pleaseSelectCrop => 'Please select a crop';

  @override
  String get pleaseEnterValidArea =>
      'Please enter a valid area greater than 0 ha';

  @override
  String get pleaseSelectState => 'Please select your state';

  @override
  String get pleaseEnterDistrict => 'Please enter your district';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get pleaseEnterPositiveNumber => 'Value must be 0 or greater';

  @override
  String get humidityRangeError => 'Humidity must be between 0% and 100%';

  @override
  String get phRangeError => 'pH must be between 0 and 14';

  @override
  String get useMyLocation => 'Use My Location';

  @override
  String get detectingLocation => 'Detecting location...';

  @override
  String get locationDetected => 'Location Detected';

  @override
  String get locationDetails => 'Detected Coordinates';

  @override
  String get farmLocationCardTitle => 'Farm Location';

  @override
  String get village => 'Village';

  @override
  String get gpsAccuracy => 'GPS Accuracy';

  @override
  String get findingLocationDetails => 'Finding your location details...';

  @override
  String get addressUnavailable => 'Address unavailable';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get locationPermissionDenied =>
      'Location permission was denied. Please allow location access to use GPS.';

  @override
  String get locationPermissionRequired =>
      'Location permission is permanently denied. Please enable it in device settings.';

  @override
  String get locationServicesDisabled =>
      'Location services are turned off. Please turn on GPS on your device.';

  @override
  String get locationTimeout =>
      'Could not fetch location in time. Please try again or ensure good GPS signal.';

  @override
  String get locationErrorGeneric =>
      'Unable to retrieve location. Please check settings and try again.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get optionalGpsNote =>
      'GPS coordinates are optional. You can still proceed with State and District.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get newRecommendation => 'New Recommendation';

  @override
  String get myOrders => 'My Orders';

  @override
  String get transportTracking => 'Transport Tracking';

  @override
  String get settings => 'Settings';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get featureComingSoon =>
      'This feature will be available in an upcoming update.';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get signOutFailed =>
      'Sign out failed. Please check your connection and try again.';

  @override
  String get menuTooltip => 'Navigation Menu';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get newFarmRecommendation => 'New Farm Recommendation';

  @override
  String get findBestMarketSubtitle =>
      'Find the best market for your vegetables';

  @override
  String get stepVegetable => 'Vegetable';

  @override
  String get selectVegetable => 'Select Vegetable';

  @override
  String get selectVegetablePrompt =>
      'Choose the vegetable you are harvesting or planning to sell';

  @override
  String get pleaseSelectVegetable => 'Please select a vegetable';

  @override
  String get stepDetails => 'Details';

  @override
  String get stepDetailsPrompt => 'Environmental and soil parameters';

  @override
  String get selected => 'Selected';

  @override
  String get vegTomato => 'Tomato';

  @override
  String get vegOnion => 'Onion';

  @override
  String get vegPotato => 'Potato';

  @override
  String get vegBrinjal => 'Brinjal';

  @override
  String get vegBhindi => 'Bhindi';

  @override
  String get vegBottleGourd => 'Bottle Gourd';

  @override
  String get vegBitterGourd => 'Bitter Gourd';

  @override
  String get vegRidgeGourd => 'Ridge Gourd';

  @override
  String get vegSnakeGourd => 'Snake Gourd';

  @override
  String get vegCabbage => 'Cabbage';

  @override
  String get vegCauliflower => 'Cauliflower';

  @override
  String get vegCarrot => 'Carrot';

  @override
  String get vegBeans => 'Beans';

  @override
  String get vegGreenPeas => 'Green Peas';

  @override
  String get vegSpinach => 'Spinach';

  @override
  String get vegCapsicum => 'Capsicum';

  @override
  String get vegGreenChilli => 'Green Chilli';

  @override
  String get farmWeather => 'Farm Weather';

  @override
  String get weatherTemperature => 'Temperature';

  @override
  String get weatherHumidity => 'Humidity';

  @override
  String get weatherRainfall => 'Rainfall';

  @override
  String get weatherWindSpeed => 'Wind Speed';

  @override
  String get gettingWeather => 'Getting weather...';

  @override
  String get weatherUpdated => 'Weather updated';

  @override
  String get weatherUnavailable => 'Weather unavailable';

  @override
  String get retry => 'Retry';

  @override
  String get weatherAvailableAfterLocation =>
      'Weather will be available after location detection';

  @override
  String get kmh => 'km/h';

  @override
  String get farmToMarketRecommendation => 'Farm-to-Market Recommendation';

  @override
  String get recommendedSellingOption => 'Recommended selling option';

  @override
  String get analyzingFarmDetails => 'Analyzing your farm details';

  @override
  String get analysisComplete => 'Analysis Complete';

  @override
  String get recommendedMarketTitle => 'Recommended Market';

  @override
  String get marketNameLabel => 'Market Name';

  @override
  String get buyerLabel => 'Buyer';

  @override
  String get expectedPrice => 'Expected Price';

  @override
  String get expectedNetRevenue => 'Expected Net Revenue';

  @override
  String get expectedSupply => 'Expected Supply';

  @override
  String get tonnes => 'tonnes';

  @override
  String get kg => 'kg';

  @override
  String get cropLabel => 'Crop';

  @override
  String get farmAreaLabel => 'Farm Area';

  @override
  String get marketComparisonTitle => 'Market Comparison';

  @override
  String get saleableQuantity => 'Saleable Quantity';

  @override
  String get transportCost => 'Transport Cost';

  @override
  String get spoilageLabel => 'Spoilage';

  @override
  String get demandStatusLabel => 'Demand Status';

  @override
  String get lowDemand => 'Low Demand';

  @override
  String get mediumDemand => 'Medium Demand';

  @override
  String get highDemand => 'High Demand';

  @override
  String get whyThisRecommendationTitle => 'Why this recommendation?';

  @override
  String get recommendationReasonDefault =>
      'Highest feasible net expected revenue after transport cost, while accounting for spoilage and buyer capacity.';

  @override
  String get transportRouteTitle => 'Transport Route';

  @override
  String get farmOrigin => 'Farm';

  @override
  String get travelTimeLabel => 'Travel time';

  @override
  String get freshnessSpoilageTitle => 'Freshness & Spoilage';

  @override
  String get freshnessLabel => 'Freshness';

  @override
  String get rottenLabel => 'Rotten';

  @override
  String get spoilageRisk => 'Spoilage Risk';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get lowRisk => 'LOW';

  @override
  String get spoiledQuantity => 'Spoiled Quantity';

  @override
  String get priceDetailsTitle => 'Price Analysis';

  @override
  String get currentMarketPrice => 'Current Market Price';

  @override
  String get predictedFuturePrice => 'Predicted Future Price';

  @override
  String get currentModalPrice => 'Current Modal Price';

  @override
  String get predictedFutureModalPrice => 'Predicted Future Modal Price';

  @override
  String get perKg => 'per kg';

  @override
  String get perQuintal => 'quintal';

  @override
  String get demandBuyerCapacityTitle => 'Demand & Buyer Capacity';

  @override
  String get demandLabel => 'Demand';

  @override
  String get buyerCapacity => 'Buyer Capacity';

  @override
  String get availableCapacity => 'Available Capacity';

  @override
  String get demandCoverage => 'Demand Coverage';

  @override
  String get capacityStatus => 'Capacity Status';

  @override
  String get capacityAvailable => 'Available';

  @override
  String get viewMarketDetails => 'View Market Details';

  @override
  String get startNewRecommendation => 'Start New Recommendation';

  @override
  String get marketDetailsNote => 'Detailed market trade and logistics view.';
}
