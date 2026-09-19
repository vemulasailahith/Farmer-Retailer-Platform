import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/vegetable_item.dart';
import '../../services/location_service.dart';
import '../../services/reverse_geocoding_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/farmer_drawer.dart';
import '../../widgets/language_selector.dart';
import 'recommendation_screen.dart';

class FarmerInputScreen extends StatefulWidget {
  const FarmerInputScreen({super.key});

  @override
  State<FarmerInputScreen> createState() => _FarmerInputScreenState();
}

class _FarmerInputScreenState extends State<FarmerInputScreen> {
  int _currentStep = 0;

  // Form Keys for step validation
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Location, Geocoding & Weather Services
  final LocationService _locationService = LocationService();
  final ReverseGeocodingService _reverseGeocodingService = ReverseGeocodingService();
  final WeatherService _weatherService = WeatherService();

  // Weather state (exposed for upcoming supply model contract integration)
  WeatherData? _weatherData;
  bool _isLoadingWeather = false;
  bool _weatherError = false;

  /// Exposes current weather data in screen state
  WeatherData? get weatherData => _weatherData;

  // Step 1: Crop Selection (Initially empty, requires explicit user selection)
  String? _selectedCrop;

  // Step 2: Farm Area (Initially empty)
  final _areaController = TextEditingController();

  // Step 3: Location (State, District + GPS coordinates, accuracy & reverse geocoded address)
  String? _selectedState;
  final _districtController = TextEditingController();
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  String? _village;
  String? _reverseDistrict;
  String? _reverseState;
  bool _isReverseGeocoding = false;
  bool _isFetchingLocation = false;
  String? _locationErrorMessage;

  // Step 4: Advanced Environmental & Farming Inputs (Initially empty)
  final _yearController = TextEditingController();
  final _nReqController = TextEditingController();
  final _pReqController = TextEditingController();
  final _kReqController = TextEditingController();
  final _tempController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _windSpeedController = TextEditingController();
  final _solarController = TextEditingController();

  // Available States
  final List<String> _states = [
    'Andhra Pradesh',
    'Telangana',
    'Karnataka',
    'Tamil Nadu',
  ];

  @override
  void dispose() {
    _areaController.dispose();
    _districtController.dispose();
    _yearController.dispose();
    _nReqController.dispose();
    _pReqController.dispose();
    _kReqController.dispose();
    _tempController.dispose();
    _humidityController.dispose();
    _phController.dispose();
    _rainfallController.dispose();
    _windSpeedController.dispose();
    _solarController.dispose();
    super.dispose();
  }

  void _onStepContinue() {
    bool isCurrentStepValid = false;

    if (_currentStep == 0) {
      if (_selectedCrop != null && _selectedCrop!.isNotEmpty) {
        isCurrentStepValid = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseSelectVegetable),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else if (_currentStep == 1) {
      isCurrentStepValid = _step2FormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 2) {
      isCurrentStepValid = _step3FormKey.currentState?.validate() ?? false;
    } else if (_currentStep == 3) {
      isCurrentStepValid = _step4FormKey.currentState?.validate() ?? false;
    }

    if (isCurrentStepValid) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep += 1;
        });
      } else {
        _handleFinalSubmit();
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationErrorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    final result = await _locationService.getCurrentLocation();

    if (!mounted) return;

    setState(() {
      _isFetchingLocation = false;
    });

    if (result.isSuccess && result.latitude != null && result.longitude != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _accuracy = result.accuracy;
        _locationErrorMessage = null;
        _isReverseGeocoding = true;
        _village = null;
        _reverseDistrict = null;
        _reverseState = null;
        _weatherData = null;
        _weatherError = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.locationDetected,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Asynchronously fetch current weather for detected coordinates
      _fetchWeather(result.latitude!, result.longitude!);

      // Asynchronously query reverse geocoding for village, district, state
      try {
        final addressDetails = await _reverseGeocodingService.reverseGeocode(
          latitude: result.latitude!,
          longitude: result.longitude!,
        );

        if (!mounted) return;

        setState(() {
          _isReverseGeocoding = false;
          if (addressDetails != null && !addressDetails.isEmpty) {
            _village = addressDetails.village;
            _reverseDistrict = addressDetails.district;
            _reverseState = addressDetails.state;

            // Auto-select state if recognized in supported state list
            if (addressDetails.state != null) {
              final matchedState = _states.firstWhere(
                (st) => st.toLowerCase() == addressDetails.state!.toLowerCase(),
                orElse: () => '',
              );
              if (matchedState.isNotEmpty) {
                _selectedState = matchedState;
              }
            }

            // Auto-fill district if input field is currently empty
            if (addressDetails.district != null && _districtController.text.trim().isEmpty) {
              _districtController.text = addressDetails.district!;
            }
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isReverseGeocoding = false;
        });
      }
    } else {
      String errorMsg;
      switch (result.errorType) {
        case LocationErrorType.serviceDisabled:
          errorMsg = l10n.locationServicesDisabled;
          break;
        case LocationErrorType.permissionDenied:
          errorMsg = l10n.locationPermissionDenied;
          break;
        case LocationErrorType.permissionDeniedForever:
          errorMsg = l10n.locationPermissionRequired;
          break;
        case LocationErrorType.timeout:
          errorMsg = l10n.locationTimeout;
          break;
        default:
          errorMsg = l10n.locationErrorGeneric;
          break;
      }

      setState(() {
        _locationErrorMessage = errorMsg;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          action: result.errorType == LocationErrorType.permissionDeniedForever
              ? SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () => _locationService.openAppSettings(),
                )
              : result.errorType == LocationErrorType.serviceDisabled
                  ? SnackBarAction(
                      label: 'Settings',
                      textColor: Colors.white,
                      onPressed: () => _locationService.openLocationSettings(),
                    )
                  : SnackBarAction(
                      label: l10n.tryAgain,
                      textColor: Colors.white,
                      onPressed: _fetchCurrentLocation,
                    ),
        ),
      );
    }
  }

  /// Fetches weather from Open-Meteo for the detected coordinates without blocking the farmer
  Future<void> _fetchWeather(double lat, double lon) async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = false;
    });

    final weather = await _weatherService.getWeather(
      latitude: lat,
      longitude: lon,
    );

    if (!mounted) return;

    setState(() {
      _isLoadingWeather = false;
      if (weather != null) {
        _weatherData = weather;
        _weatherError = false;
      } else {
        _weatherError = true;
      }
    });
  }

  void _handleFinalSubmit() {
    final l10n = AppLocalizations.of(context)!;

    // Collect all inputs into structured dictionary
    final collectedData = {
      'crop': _selectedCrop,
      'area_ha': double.tryParse(_areaController.text.trim()) ?? 0.0,
      'state_name': _selectedState,
      'dist_name': _districtController.text.trim(),
      'latitude': _latitude,
      'longitude': _longitude,
      'year': int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
      'n_req_kg_per_ha': double.tryParse(_nReqController.text.trim()) ?? 0.0,
      'p_req_kg_per_ha': double.tryParse(_pReqController.text.trim()) ?? 0.0,
      'k_req_kg_per_ha': double.tryParse(_kReqController.text.trim()) ?? 0.0,
      'temperature_c': double.tryParse(_tempController.text.trim()) ?? 0.0,
      'humidity_percent': double.tryParse(_humidityController.text.trim()) ?? 0.0,
      'ph': double.tryParse(_phController.text.trim()) ?? 7.0,
      'rainfall_mm': double.tryParse(_rainfallController.text.trim()) ?? 0.0,
      'wind_speed_m_s': double.tryParse(_windSpeedController.text.trim()) ?? 0.0,
      'solar_radiation_mj_m2_day': double.tryParse(_solarController.text.trim()) ?? 0.0,
    };

    if (kDebugMode) {
      debugPrint('================ COLLECTED FARMER INPUTS ================');
      debugPrint('$collectedData');
      debugPrint('========================================================');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.inputsCollectedSuccess,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to RecommendationScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RecommendationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.farmerInputTitle),
        actions: const [
          LanguageSelector(),
        ],
      ),
      drawer: const FarmerDrawer(),
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF2E7D32),
                ),
          ),
          child: Column(
            children: [
              _buildHeader(l10n),
              _buildProgressIndicator(l10n),
              Expanded(
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepTapped: (step) {
                    setState(() => _currentStep = step);
                  },
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    final isLastStep = _currentStep == 3;
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                isLastStep ? l10n.continueButton : '${l10n.next} →',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          if (_currentStep > 0) ...[
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: Text(
                                l10n.back,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  steps: [
                    // STEP 1: VEGETABLE SELECTION
                    Step(
                      title: Text(
                        l10n.stepVegetable,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(l10n.selectVegetablePrompt),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                      content: _buildVegetableSelectionStep(l10n),
                    ),

                    // STEP 2: FARM AREA
                    Step(
                      title: Text(
                        l10n.stepArea,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(l10n.farmAreaPrompt),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                      content: _buildAreaStep(l10n),
                    ),

                    // STEP 3: FARM LOCATION
                    Step(
                      title: Text(
                        l10n.stepLocation,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(l10n.farmLocationPrompt),
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                      content: _buildLocationStep(l10n),
                    ),

                    // STEP 4: DETAILS
                    Step(
                      title: Text(
                        l10n.stepDetails,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(l10n.stepDetailsPrompt),
                      isActive: _currentStep >= 3,
                      state: _currentStep == 3 ? StepState.editing : StepState.indexed,
                      content: _buildEnvironmentStep(l10n),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header Banner Card
  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.newFarmRecommendation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.findBestMarketSubtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Progress Indicator (① Vegetable ② Farm Area ③ Location ④ Details)
  Widget _buildProgressIndicator(AppLocalizations l10n) {
    final steps = [
      {'num': '1', 'label': l10n.stepVegetable},
      {'num': '2', 'label': l10n.stepArea},
      {'num': '3', 'label': l10n.stepLocation},
      {'num': '4', 'label': l10n.stepDetails},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isPassed = _currentStep > stepBefore;
            return Expanded(
              child: Container(
                height: 2.5,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isPassed ? const Color(0xFF2E7D32) : Colors.grey.shade300,
              ),
            );
          }

          final stepIdx = index ~/ 2;
          final isActive = _currentStep == stepIdx;
          final isCompleted = _currentStep > stepIdx;

          return InkWell(
            onTap: () {
              setState(() => _currentStep = stepIdx);
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF2E7D32)
                          : (isCompleted ? const Color(0xFFE8F5E9) : Colors.grey.shade100),
                      border: Border.all(
                        color: (isActive || isCompleted)
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                        width: isActive ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Color(0xFF2E7D32))
                        : Text(
                            steps[stepIdx]['num']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.grey.shade600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[stepIdx]['label']!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // Widget for Step 1: Responsive Vegetable Selection Grid with Large Visual Touch Targets
  Widget _buildVegetableSelectionStep(AppLocalizations l10n) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 2;
              if (width >= 900) {
                crossAxisCount = 4;
              } else if (width >= 600) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: supportedVegetables.length,
                itemBuilder: (context, index) {
                  final veg = supportedVegetables[index];
                  final isSelected = _selectedCrop == veg.backendName;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCrop = veg.backendName;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1.2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF2E7D32).withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: isSelected ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: isSelected
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.check, size: 12, color: Colors.white),
                                        const SizedBox(width: 3),
                                        Text(
                                          l10n.selected,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(height: 18),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: veg.primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              veg.icon,
                              size: 30,
                              color: veg.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            veg.getLocalizedName(l10n),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? const Color(0xFF1B5E20) : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget for Step 2: Farm Area
  Widget _buildAreaStep(AppLocalizations l10n) {
    return Form(
      key: _step2FormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _areaController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: l10n.areaInHectares,
                prefixIcon: const Icon(Icons.aspect_ratio),
                suffixText: l10n.hectares,
                helperText: l10n.areaHelper,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterValidArea;
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return l10n.pleaseEnterValidArea;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget for Step 3: Location
  Widget _buildLocationStep(AppLocalizations l10n) {
    return Form(
      key: _step3FormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // State Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedState,
              hint: Text(l10n.selectState),
              decoration: InputDecoration(
                labelText: l10n.state,
                prefixIcon: const Icon(Icons.map_outlined),
              ),
              items: _states.map((st) {
                return DropdownMenuItem<String>(
                  value: st,
                  child: Text(st, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedState = val);
                }
              },
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return l10n.pleaseSelectState;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // District Input
            TextFormField(
              controller: _districtController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: l10n.district,
                prefixIcon: const Icon(Icons.location_city_outlined),
                helperText: l10n.districtHelper,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterDistrict;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Divider and GPS section
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'GPS',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              l10n.optionalGpsNote,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Prominent "Use My Location" Button (Min 52px touch target)
            ElevatedButton.icon(
              onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
              icon: _isFetchingLocation
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.my_location, size: 24),
              label: Text(
                _isFetchingLocation ? l10n.detectingLocation : l10n.useMyLocation,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            ),

            // Detected Farm Location Card (Village, District, State, Lat, Lon, Accuracy)
            if (_latitude != null && _longitude != null) ...[
              const SizedBox(height: 16),
              _buildDetectedLocationCard(l10n),
              const SizedBox(height: 16),
              _buildWeatherCard(l10n),
            ] else ...[
              if (_locationErrorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationErrorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(l10n.tryAgain),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildWeatherCard(l10n),
            ],
          ],
        ),
      ),
    );
  }

  // Farmer-friendly Detected Location Card matching the vegetable theme
  Widget _buildDetectedLocationCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Large Location Icon + Farm Location Title + Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF2E7D32),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.farmLocationCardTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          l10n.locationDetected,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Address Details Section: Village, District, State
          if (_isReverseGeocoding) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.findingLocationDetails,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 500;
                final villageVal = _village ?? l10n.addressUnavailable;
                final districtVal = _reverseDistrict ??
                    (_districtController.text.isNotEmpty ? _districtController.text : l10n.addressUnavailable);
                final stateVal = _reverseState ?? (_selectedState ?? l10n.addressUnavailable);

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildLocationInfoTile(
                          l10n.village,
                          villageVal,
                          Icons.holiday_village_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildLocationInfoTile(
                          l10n.district,
                          districtVal,
                          Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildLocationInfoTile(
                          l10n.state,
                          stateVal,
                          Icons.map_outlined,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLocationInfoTile(
                        l10n.village,
                        villageVal,
                        Icons.holiday_village_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildLocationInfoTile(
                        l10n.district,
                        districtVal,
                        Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildLocationInfoTile(
                        l10n.state,
                        stateVal,
                        Icons.map_outlined,
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 14),
          ],

          const Divider(height: 1),
          const SizedBox(height: 14),

          // Coordinates & GPS Accuracy Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 500;
              final accuracyText = _accuracy != null
                  ? '±${_accuracy!.round()} m'
                  : l10n.addressUnavailable;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildLocationInfoTile(
                        l10n.latitude,
                        _latitude!.toStringAsFixed(6),
                        Icons.my_location,
                        isMonospace: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildLocationInfoTile(
                        l10n.longitude,
                        _longitude!.toStringAsFixed(6),
                        Icons.my_location,
                        isMonospace: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildLocationInfoTile(
                        l10n.gpsAccuracy,
                        accuracyText,
                        Icons.gps_fixed,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildLocationInfoTile(
                            l10n.latitude,
                            _latitude!.toStringAsFixed(6),
                            Icons.my_location,
                            isMonospace: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildLocationInfoTile(
                            l10n.longitude,
                            _longitude!.toStringAsFixed(6),
                            Icons.my_location,
                            isMonospace: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildLocationInfoTile(
                      l10n.gpsAccuracy,
                      accuracyText,
                      Icons.gps_fixed,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Helper tile widget for clean information display
  Widget _buildLocationInfoTile(
    String label,
    String value,
    IconData icon, {
    bool isMonospace = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBE7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: isMonospace ? 'monospace' : null,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Farmer-friendly Weather Card matching the green-and-white theme
  Widget _buildWeatherCard(AppLocalizations l10n) {
    final hasLocation = _latitude != null && _longitude != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _weatherError
              ? Colors.orange.shade300
              : const Color(0xFF2E7D32),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Weather Emoji + Title + Status Subtitle / Retry Action
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '🌦️',
                  style: TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.farmWeather,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildWeatherStatusSubtitle(l10n, hasLocation),
                  ],
                ),
              ),
              if (hasLocation && _weatherError && !_isLoadingWeather)
                TextButton.icon(
                  onPressed: () => _fetchWeather(_latitude!, _longitude!),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(l10n.retry),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),

          // Weather Card Body
          if (!hasLocation) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.weatherAvailableAfterLocation,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_isLoadingWeather) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.gettingWeather,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_weatherData != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildWeatherMetricsList(l10n, _weatherData!),
          ] else if (_weatherError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_outlined, color: Colors.orange.shade800, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.weatherUnavailable,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeatherStatusSubtitle(AppLocalizations l10n, bool hasLocation) {
    if (!hasLocation) {
      return Text(
        l10n.weatherAvailableAfterLocation,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_isLoadingWeather) {
      return Text(
        l10n.gettingWeather,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E7D32),
        ),
      );
    }

    if (_weatherData != null) {
      return Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            l10n.weatherUpdated,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      );
    }

    return Text(
      l10n.weatherUnavailable,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.orange.shade800,
      ),
    );
  }

  Widget _buildWeatherMetricsList(AppLocalizations l10n, WeatherData weather) {
    return Column(
      children: [
        _buildWeatherMetricRow(
          label: l10n.weatherTemperature,
          value: '${_formatWeatherNumber(weather.temperature)}${l10n.celsius}',
          icon: Icons.thermostat_outlined,
        ),
        const SizedBox(height: 8),
        _buildWeatherMetricRow(
          label: l10n.weatherHumidity,
          value: '${weather.humidity.round()}${l10n.percent}',
          icon: Icons.water_drop_outlined,
        ),
        const SizedBox(height: 8),
        _buildWeatherMetricRow(
          label: l10n.weatherRainfall,
          value: '${weather.rainfall.toStringAsFixed(1)} ${l10n.mm}',
          icon: Icons.grain_outlined,
        ),
        const SizedBox(height: 8),
        _buildWeatherMetricRow(
          label: l10n.weatherWindSpeed,
          value: '${_formatWeatherNumber(weather.windSpeed)} ${l10n.kmh}',
          icon: Icons.air_outlined,
        ),
      ],
    );
  }

  Widget _buildWeatherMetricRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBE7).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ],
      ),
    );
  }

  String _formatWeatherNumber(double val) {
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  // Widget for Step 4: Advanced Environmental & Soil Parameters
  Widget _buildEnvironmentStep(AppLocalizations l10n) {
    return Form(
      key: _step4FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informational Banner explaining these are advanced inputs that can be automated
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.advancedEnvironmentTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.environmentalAutoFetchNote,
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Crop Year
          _buildNumericField(
            controller: _yearController,
            label: l10n.year,
            icon: Icons.calendar_today_outlined,
            isInteger: true,
            minValue: 2000,
            maxValue: 2100,
            l10n: l10n,
          ),
          const SizedBox(height: 16),

          // Soil Nutrients Group
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science_outlined, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.soilNutrients,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildNumericField(
                    controller: _nReqController,
                    label: l10n.nitrogen,
                    unit: l10n.kgPerHa,
                    icon: Icons.eco_outlined,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _pReqController,
                    label: l10n.phosphorus,
                    unit: l10n.kgPerHa,
                    icon: Icons.eco_outlined,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _kReqController,
                    label: l10n.potassium,
                    unit: l10n.kgPerHa,
                    icon: Icons.eco_outlined,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _phController,
                    label: l10n.soilPh,
                    unit: 'pH',
                    icon: Icons.water_drop_outlined,
                    minValue: 0.0,
                    maxValue: 14.0,
                    customRangeError: l10n.phRangeError,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weather & Environment Group
          Card(
            elevation: 0,
            color: Colors.grey.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.weatherClimate,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildNumericField(
                    controller: _tempController,
                    label: l10n.temperature,
                    unit: l10n.celsius,
                    icon: Icons.thermostat_outlined,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _humidityController,
                    label: l10n.humidity,
                    unit: l10n.percent,
                    icon: Icons.cloud_outlined,
                    minValue: 0.0,
                    maxValue: 100.0,
                    customRangeError: l10n.humidityRangeError,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _rainfallController,
                    label: l10n.rainfall,
                    unit: l10n.mm,
                    icon: Icons.water_outlined,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _windSpeedController,
                    label: l10n.windSpeed,
                    unit: l10n.mPerS,
                    icon: Icons.air_outlined,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 12),
                  _buildNumericField(
                    controller: _solarController,
                    label: l10n.solarRadiation,
                    unit: l10n.mjPerM2Day,
                    icon: Icons.light_mode_outlined,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumericField({
    required TextEditingController controller,
    required String label,
    required AppLocalizations l10n,
    String? unit,
    IconData? icon,
    bool isInteger = false,
    double? minValue = 0.0,
    double? maxValue,
    String? customRangeError,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        suffixText: unit,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.pleaseEnterValidNumber;
        }
        final parsed = double.tryParse(value.trim());
        if (parsed == null) {
          return l10n.pleaseEnterValidNumber;
        }
        if (minValue != null && parsed < minValue) {
          return customRangeError ?? l10n.pleaseEnterPositiveNumber;
        }
        if (maxValue != null && parsed > maxValue) {
          return customRangeError ?? l10n.pleaseEnterValidNumber;
        }
        return null;
      },
    );
  }
}
