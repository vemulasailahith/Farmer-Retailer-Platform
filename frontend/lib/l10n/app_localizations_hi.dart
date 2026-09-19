// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'फार्म-टू-मार्केट';

  @override
  String get login => 'लॉगिन';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get password => 'पासवर्ड';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get farmer => 'किसान';

  @override
  String get retailer => 'खुदरा विक्रेता';

  @override
  String get createAccountButton => 'खाता बनाएं';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'लॉग आउट';

  @override
  String get farmerDashboard => 'किसान डैशबोर्ड';

  @override
  String get welcomeFarmer => 'स्वागत है, किसान भाई!';

  @override
  String get welcomeFarmerSubtitle =>
      'स्मार्ट फसल अनुशंसा और बाजार मूल्य यहां प्रदर्शित होंगे।';

  @override
  String get profileError => 'प्रोफ़ाइल त्रुटि';

  @override
  String get profileErrorMessage =>
      'डेटाबेस से आपकी प्रोफ़ाइल लोड करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get returnToLogin => 'लॉगिन पर लौटें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'त्रुटि';

  @override
  String get appSubtitle => 'स्मार्ट फसल निर्णय और बाजार जुड़ाव';

  @override
  String get dontHaveAccount => 'खाता नहीं है? ';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है? ';

  @override
  String get register => 'पंजीकरण करें';

  @override
  String get registeringAs => 'पंजीकरण भूमिका';

  @override
  String get verifyingPermissions => 'अनुमतियों की पुष्टि की जा रही है...';

  @override
  String get pleaseEnterFullName => 'कृपया अपना पूरा नाम दर्ज करें';

  @override
  String get pleaseEnterEmail => 'कृपया अपना ईमेल दर्ज करें';

  @override
  String get pleaseEnterValidEmail => 'कृपया मान्य ईमेल पता दर्ज करें';

  @override
  String get pleaseEnterPassword => 'कृपया पासवर्ड दर्ज करें';

  @override
  String get passwordMinLength => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खा रहे हैं';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get farmerInputTitle => 'किसान विवरण प्रविष्टि';

  @override
  String get farmerInputSubtitle =>
      'सटीक बाजार अनुशंसा के लिए अपने खेत का विवरण दर्ज करें';

  @override
  String get startCropRecommendation => 'नई फसल अनुशंसा';

  @override
  String get stepCrop => 'फसल';

  @override
  String get stepArea => 'क्षेत्रफल';

  @override
  String get stepLocation => 'स्थान';

  @override
  String get stepEnvironment => 'पर्यावरण';

  @override
  String get cropSelection => 'फसल चुनें';

  @override
  String get cropSelectionPrompt =>
      'वह फसल चुनें जिसे आप बेच रहे हैं या बेचने की योजना बना रहे हैं';

  @override
  String get rice => 'चावल / धान';

  @override
  String get maize => 'मक्का';

  @override
  String get chickpea => 'चना';

  @override
  String get cotton => 'कपास';

  @override
  String get farmArea => 'खेत का क्षेत्रफल';

  @override
  String get farmAreaPrompt => 'कुल खेती का क्षेत्रफल दर्ज करें';

  @override
  String get areaInHectares => 'खेती का क्षेत्रफल (हेक्टेयर)';

  @override
  String get hectares => 'हेक्टेयर';

  @override
  String get areaHelper => 'उदाहरण: 5.0 हेक्टेयर';

  @override
  String get farmLocation => 'खेत का स्थान';

  @override
  String get farmLocationPrompt => 'चुनें कि आपका खेत कहाँ स्थित है';

  @override
  String get state => 'राज्य';

  @override
  String get district => 'जिला';

  @override
  String get selectState => 'राज्य चुनें';

  @override
  String get enterDistrict => 'जिले का नाम दर्ज करें';

  @override
  String get districtHelper => 'उदाहरण: गुंटूर, कृष्णा';

  @override
  String get farmEnvironment => 'मिट्टी और मौसम का विवरण';

  @override
  String get farmEnvironmentPrompt =>
      'अपने खेत के लिए मिट्टी और मौसमी मौसम के अनुमान दर्ज करें';

  @override
  String get advancedEnvironmentTitle => 'उन्नत पर्यावरणीय विवरण';

  @override
  String get environmentalAutoFetchNote =>
      'नोट: भविष्य के अपडेट में, आपके खेत के स्थान के आधार पर ये मिट्टी और मौसम के विवरण अपने आप भर दिए जाएंगे।';

  @override
  String get soilNutrients => 'मिट्टी के पोषक तत्व (NPK)';

  @override
  String get weatherClimate => 'मौसम और जलवायु';

  @override
  String get year => 'फसल वर्ष';

  @override
  String get nitrogen => 'नाइट्रोजन (N) की आवश्यकता';

  @override
  String get phosphorus => 'फास्फोरस (P) की आवश्यकता';

  @override
  String get potassium => 'पोटेशियम (K) की आवश्यकता';

  @override
  String get temperature => 'औसत तापमान';

  @override
  String get humidity => 'सापेक्ष आर्द्रता';

  @override
  String get soilPh => 'मिट्टी का pH स्तर';

  @override
  String get rainfall => 'मौसमी वर्षा';

  @override
  String get windSpeed => 'हवा की गति';

  @override
  String get solarRadiation => 'सौर विकिरण';

  @override
  String get kgPerHa => 'किग्रा/हेक्टेयर';

  @override
  String get celsius => '°C';

  @override
  String get percent => '%';

  @override
  String get mm => 'मिमी';

  @override
  String get mPerS => 'मी/से';

  @override
  String get mjPerM2Day => 'MJ/मी²/दिन';

  @override
  String get next => 'आगे';

  @override
  String get back => 'पीछे';

  @override
  String get continueButton => 'जारी रखें';

  @override
  String get inputsCollectedSuccess =>
      'किसान का विवरण सफलतापूर्वक एकत्र किया गया!';

  @override
  String get pleaseSelectCrop => 'कृपया एक फसल चुनें';

  @override
  String get pleaseEnterValidArea =>
      'कृपया 0 से अधिक मान्य क्षेत्रफल दर्ज करें';

  @override
  String get pleaseSelectState => 'कृपया अपना राज्य चुनें';

  @override
  String get pleaseEnterDistrict => 'कृपया अपना जिला दर्ज करें';

  @override
  String get pleaseEnterValidNumber => 'कृपया एक मान्य संख्या दर्ज करें';

  @override
  String get pleaseEnterPositiveNumber => 'मान 0 या उससे अधिक होना चाहिए';

  @override
  String get humidityRangeError => 'आर्द्रता 0% और 100% के बीच होनी चाहिए';

  @override
  String get phRangeError => 'pH 0 और 14 के बीच होना चाहिए';

  @override
  String get useMyLocation => 'मेरी वर्तमान स्थिति का उपयोग करें (GPS)';

  @override
  String get detectingLocation => 'स्थान का पता लगाया जा रहा है...';

  @override
  String get locationDetected => 'स्थान का पता चला';

  @override
  String get locationDetails => 'प्राप्त स्थान का विवरण';

  @override
  String get farmLocationCardTitle => 'खेत का स्थान';

  @override
  String get village => 'गाँव / इलाका';

  @override
  String get gpsAccuracy => 'GPS सटीकता';

  @override
  String get findingLocationDetails => 'स्थान विवरण खोजा जा रहा है...';

  @override
  String get addressUnavailable => 'पता अनुपलब्ध है';

  @override
  String get latitude => 'अक्षांश (Latitude)';

  @override
  String get longitude => 'देशांतर (Longitude)';

  @override
  String get locationPermissionDenied =>
      'स्थान की अनुमति अस्वीकार कर दी गई। GPS उपयोग के लिए कृपया अनुमति दें।';

  @override
  String get locationPermissionRequired =>
      'स्थान अनुमति स्थायी रूप से बंद है। कृपया डिवाइस सेटिंग में जाकर इसे सक्षम करें।';

  @override
  String get locationServicesDisabled =>
      'लोकेशन सेवाएं बंद हैं। कृपया अपने डिवाइस पर GPS चालू करें।';

  @override
  String get locationTimeout =>
      'समय पर स्थान प्राप्त नहीं हो सका। कृपया पुनः प्रयास करें।';

  @override
  String get locationErrorGeneric =>
      'स्थान प्राप्त करने में असमर्थ। कृपया पुनः प्रयास करें।';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get optionalGpsNote =>
      'GPS निर्देशांक वैकल्पिक हैं। आप राज्य और जिले के साथ भी आगे बढ़ सकते हैं।';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get newRecommendation => 'नई अनुशंसा';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get transportTracking => 'परिवहन ट्रैकिंग';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get comingSoon => 'शीघ्र उपलब्ध होगा';

  @override
  String get featureComingSoon => 'यह सुविधा आगामी अपडेट में उपलब्ध होगी।';

  @override
  String get signOutConfirmation => 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get signOutFailed => 'लॉग आउट विफल रहा। कृपया पुनः प्रयास करें।';

  @override
  String get menuTooltip => 'नेविगेशन मेनू';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get newFarmRecommendation => 'नई कृषि अनुशंसा';

  @override
  String get findBestMarketSubtitle =>
      'अपनी सब्जियों के लिए सर्वोत्तम बाजार खोजें';

  @override
  String get stepVegetable => 'सब्जी';

  @override
  String get selectVegetable => 'सब्जी चुनें';

  @override
  String get selectVegetablePrompt =>
      'वह सब्जी चुनें जिसे आप बेच रहे हैं या बेचने की योजना बना रहे हैं';

  @override
  String get pleaseSelectVegetable => 'कृपया एक सब्जी चुनें';

  @override
  String get stepDetails => 'विवरण';

  @override
  String get stepDetailsPrompt => 'पर्यावरण और मिट्टी के पैरामीटर';

  @override
  String get selected => 'चयनित';

  @override
  String get vegTomato => 'टमाटर';

  @override
  String get vegOnion => 'प्याज';

  @override
  String get vegPotato => 'आलू';

  @override
  String get vegBrinjal => 'बैंगन';

  @override
  String get vegBhindi => 'भिंडी';

  @override
  String get vegBottleGourd => 'लौकी';

  @override
  String get vegBitterGourd => 'करेला';

  @override
  String get vegRidgeGourd => 'तोरई';

  @override
  String get vegSnakeGourd => 'चिचिंडा';

  @override
  String get vegCabbage => 'पत्ता गोभी';

  @override
  String get vegCauliflower => 'फूल गोभी';

  @override
  String get vegCarrot => 'गाजर';

  @override
  String get vegBeans => 'बीन्स / सेम';

  @override
  String get vegGreenPeas => 'हरी मटर';

  @override
  String get vegSpinach => 'पालक';

  @override
  String get vegCapsicum => 'शिमला मिर्च';

  @override
  String get vegGreenChilli => 'हरी मिर्च';

  @override
  String get farmWeather => 'खेत का मौसम';

  @override
  String get weatherTemperature => 'तापमान';

  @override
  String get weatherHumidity => 'आर्द्रता';

  @override
  String get weatherRainfall => 'वर्षा';

  @override
  String get weatherWindSpeed => 'हवा की गति';

  @override
  String get gettingWeather => 'मौसम की जानकारी ली जा रही है...';

  @override
  String get weatherUpdated => 'मौसम अपडेट हो गया';

  @override
  String get weatherUnavailable => 'मौसम अनुपलब्ध है';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get weatherAvailableAfterLocation =>
      'स्थान की पहचान के बाद मौसम उपलब्ध होगा';

  @override
  String get kmh => 'किमी/घंटा';

  @override
  String get farmToMarketRecommendation => 'खेत-से-बाजार अनुशंसा';

  @override
  String get recommendedSellingOption => 'अनुशंसित बिक्री विकल्प';

  @override
  String get analyzingFarmDetails =>
      'आपके खेत के विवरण का विश्लेषण किया जा रहा है';

  @override
  String get analysisComplete => 'विश्लेषण पूर्ण';

  @override
  String get recommendedMarketTitle => 'अनुशंसित बाजार';

  @override
  String get marketNameLabel => 'बाजार का नाम';

  @override
  String get buyerLabel => 'खरीदार';

  @override
  String get expectedPrice => 'अपेक्षित मूल्य';

  @override
  String get expectedNetRevenue => 'अपेक्षित शुद्ध आय';

  @override
  String get expectedSupply => 'अपेक्षित आपूर्ति';

  @override
  String get tonnes => 'टन';

  @override
  String get kg => 'किग्रा';

  @override
  String get cropLabel => 'फसल';

  @override
  String get farmAreaLabel => 'खेत का क्षेत्रफल';

  @override
  String get marketComparisonTitle => 'बाजार तुलना';

  @override
  String get saleableQuantity => 'बिक्री योग्य मात्रा';

  @override
  String get transportCost => 'परिवहन लागत';

  @override
  String get spoilageLabel => 'खराबी / नुकसान';

  @override
  String get demandStatusLabel => 'मांग स्थिति';

  @override
  String get lowDemand => 'कम मांग';

  @override
  String get mediumDemand => 'मध्यम मांग';

  @override
  String get highDemand => 'अधिक मांग';

  @override
  String get whyThisRecommendationTitle => 'यह अनुशंसा क्यों?';

  @override
  String get recommendationReasonDefault =>
      'परिवहन लागत, फसल खराबी और खरीदार की क्षमता को ध्यान में रखते हुए अधिकतम शुद्ध लाभ।';

  @override
  String get transportRouteTitle => 'परिवहन मार्ग';

  @override
  String get farmOrigin => 'खेत';

  @override
  String get travelTimeLabel => 'यात्रा का समय';

  @override
  String get freshnessSpoilageTitle => 'ताजगी और खराबी का जोखिम';

  @override
  String get freshnessLabel => 'ताजगी';

  @override
  String get rottenLabel => 'सड़ा हुआ';

  @override
  String get spoilageRisk => 'खराबी का जोखिम';

  @override
  String get riskLevel => 'जोखिम स्तर';

  @override
  String get lowRisk => 'कम';

  @override
  String get spoiledQuantity => 'खराब मात्रा';

  @override
  String get priceDetailsTitle => 'मूल्य विश्लेषण';

  @override
  String get currentMarketPrice => 'वर्तमान बाजार मूल्य';

  @override
  String get predictedFuturePrice => 'अनुमानित भविष्य का मूल्य';

  @override
  String get currentModalPrice => 'वर्तमान मॉडल मूल्य';

  @override
  String get predictedFutureModalPrice => 'अनुमानित भविष्य का मॉडल मूल्य';

  @override
  String get perKg => 'प्रति किग्रा';

  @override
  String get perQuintal => 'प्रति क्विंटल';

  @override
  String get demandBuyerCapacityTitle => 'मांग और खरीदार की क्षमता';

  @override
  String get demandLabel => 'मांग';

  @override
  String get buyerCapacity => 'खरीदार क्षमता';

  @override
  String get availableCapacity => 'उपलब्ध क्षमता';

  @override
  String get demandCoverage => 'मांग कवरेज';

  @override
  String get capacityStatus => 'क्षमता स्थिति';

  @override
  String get capacityAvailable => 'उपलब्ध';

  @override
  String get viewMarketDetails => 'बाजार विवरण देखें';

  @override
  String get startNewRecommendation => 'नई अनुशंसा शुरू करें';

  @override
  String get marketDetailsNote => 'विस्तृत बाजार व्यापार और रसद दृश्य।';
}
