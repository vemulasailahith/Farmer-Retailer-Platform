import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/farmer_drawer.dart';
import '../../widgets/language_selector.dart';
import 'farmer_input_screen.dart';
import 'farmer_orders_screen.dart';
import 'live_shipment_screen.dart';
import 'recommendation_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  final int initialIndex;
  final AuthService? authService;
  const FarmerHomeScreen({super.key, this.initialIndex = 0, this.authService});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  bool _isSigningOut = false;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _confirmSignOut() async {
    if (_isSigningOut) return;

    final l10n = AppLocalizations.of(context)!;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout, color: Color(0xFF1B4332), size: 32),
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4332),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (shouldSignOut != true || !mounted) return;

    setState(() => _isSigningOut = true);

    try {
      if (widget.authService != null) {
        await widget.authService!.signOut();
      } else {
        await AuthService().signOut();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.signOutFailed),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _getAppTitle(AppLocalizations l10n) {
    switch (_currentIndex) {
      case 0:
        return 'AgroVerdant Intelligence';
      case 1:
        return 'Crop Assessment Wizard';
      case 2:
        return 'Market Recommendations';
      case 3:
        return 'Live Shipment Tracking';
      case 4:
        return 'Orders & Settlements';
      default:
        return l10n.farmerDashboard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      drawer: const FarmerDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.menuTooltip,
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        title: Text(
          _getAppTitle(l10n),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          const LanguageSelector(),
          IconButton(
            icon: _isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.logout, size: 22),
            tooltip: l10n.signOut,
            onPressed: _isSigningOut ? null : () => _confirmSignOut(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Tab 0: Farmer Dashboard
          _buildFarmerDashboardTab(context),

          // Tab 1: Recommend Wizard
          const FarmerInputScreen(),

          // Tab 2: Market Results
          const RecommendationScreen(),

          // Tab 3: Live Shipment Tracking
          const LiveShipmentScreen(isTab: true),

          // Tab 4: Orders & Settlements
          const FarmerOrdersScreen(isTab: true),
        ],
      ),
      bottomNavigationBar: _buildStitchBottomNavBar(),
    );
  }

  /// Custom bottom navigation bar faithfully matching the Stitch UI design specifications
  Widget _buildStitchBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(245),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4332).withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavTabItem(
                index: 0,
                icon: Icons.home_rounded,
                inactiveIcon: Icons.home_outlined,
                label: 'Dashboard',
              ),
              _buildNavTabItem(
                index: 1,
                icon: Icons.auto_awesome,
                inactiveIcon: Icons.auto_awesome_outlined,
                label: 'Recommend',
              ),
              _buildNavTabItem(
                index: 2,
                icon: Icons.analytics,
                inactiveIcon: Icons.analytics_outlined,
                label: 'Results',
              ),
              _buildNavTabItem(
                index: 3,
                icon: Icons.local_shipping_rounded,
                inactiveIcon: Icons.local_shipping_outlined,
                label: 'Shipments',
              ),
              _buildNavTabItem(
                index: 4,
                icon: Icons.receipt_long_rounded,
                inactiveIcon: Icons.receipt_long_outlined,
                label: 'Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTabItem({
    required int index,
    required IconData icon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          splashColor: const Color(0xFFD8F3DC),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD8F3DC) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isSelected ? icon : inactiveIcon,
                  size: 22,
                  color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF1B4332) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Complete Farmer Dashboard Tab UI matching stitch_farmvalue_agricultural_platform_ui
  Widget _buildFarmerDashboardTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Farmer Welcome & Location Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD8F3DC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.nature_people, size: 16, color: Color(0xFF1B4332)),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'KISAN ID: TS-8842',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Namaste, Ramesh Rao!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B4332),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.pin_drop, size: 14, color: Color(0xFF40916C)),
                      SizedBox(width: 4),
                      Text(
                        'Shamshabad, Rangareddy Dist, Telangana',
                        style: TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF40916C)),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 2. High-Impact Primary Harvest Action CTA Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withAlpha(40),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.psychology_alt, color: Color(0xFFD8F3DC), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'AI Decision Engine',
                            style: TextStyle(color: Color(0xFFD8F3DC), fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.eco, color: Color(0xFF52B788), size: 28),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ready for Harvest? Get Market Recommendation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Compare 14 Mandis & Direct FPO Buyers for max net revenue after logistics & spoilage cuts.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _onTabSelected(1), // Switch directly to Recommend tab
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B4332),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      icon: const Text('Start Analysis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      label: const Icon(Icons.arrow_forward, size: 16),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '+18.4%',
                          style: TextStyle(color: Color(0xFF52B788), fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        Text(
                          'Net uplift',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Quick Metrics 2x2 Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: [
              _buildMetricCard(
                title: 'LAND AREA',
                value: '4.2',
                unit: 'Ha',
                subtext: 'Tomato & Capsicum',
                icon: Icons.crop_square,
                accentColor: const Color(0xFF40916C),
              ),
              _buildMetricCard(
                title: 'EST. YIELD',
                value: '18.4',
                unit: 'Ton',
                subtext: 'In ~5 days',
                icon: Icons.agriculture,
                accentColor: const Color(0xFF40916C),
              ),
              _buildMetricCard(
                title: 'DISPATCH',
                value: '2',
                unit: 'Trips',
                subtext: 'To Bowenpally Hub',
                icon: Icons.local_shipping,
                accentColor: const Color(0xFF40916C),
                onTap: () => _onTabSelected(3),
              ),
              _buildMetricCard(
                title: 'NET REALIZATION',
                value: '₹28.50',
                unit: '/kg',
                subtext: '+18% vs Mandi',
                icon: Icons.payments,
                accentColor: const Color(0xFF2D6A4F),
                isHighlight: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4. Farm Micro-climate Weather Node
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud, color: Color(0xFF40916C), size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Farm Micro-climate',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Color(0xFF2D6A4F)),
                          SizedBox(width: 4),
                          Text('Harvest Window: Optimal',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Shamshabad Agro-Meteorology Node',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WeatherItem(label: 'Temp', value: '29°C', note: 'Dry & Fair'),
                      _WeatherItem(label: 'Humidity', value: '64%', note: 'Normal'),
                      _WeatherItem(label: 'Rainfall', value: '0.0mm', note: '0% 48h'),
                      _WeatherItem(label: 'Soil Moist.', value: '42%', note: 'Ideal'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Live Rate Benchmarking Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4332).withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics, color: Color(0xFF40916C), size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Live Rate Benchmarking',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => _onTabSelected(2),
                      child: const Row(
                        children: [
                          Text('View 14 Mandis', style: TextStyle(color: Color(0xFF40916C), fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.chevron_right, size: 16, color: Color(0xFF40916C)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Crop: Hybrid Tomato (Grade A)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                _buildMandiRateItem(
                  name: 'Reliance Fresh Hub (Direct FPO)',
                  price: '₹34.50',
                  distance: '28 km away',
                  tag: 'Top Net Pay',
                  progress: 0.95,
                  isTop: true,
                ),
                const SizedBox(height: 8),
                _buildMandiRateItem(
                  name: 'Bowenpally APMC Mandi',
                  price: '₹32.00',
                  distance: '34 km away',
                  tag: '+₹3.5 Today',
                  progress: 0.82,
                ),
                const SizedBox(height: 8),
                _buildMandiRateItem(
                  name: 'Gaddiannaram Mandi',
                  price: '₹29.00',
                  distance: '24 km away',
                  tag: 'Stable',
                  progress: 0.70,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 6. Fast Shortcuts Grid
          const Text(
            'QUICK FARM ACTIONS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.8),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.add_circle,
                  label: 'New Harvest',
                  onTap: () => _onTabSelected(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.local_shipping,
                  label: 'Shipments',
                  onTap: () => _onTabSelected(3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildShortcutButton(
                  icon: Icons.receipt_long,
                  label: 'Past Orders',
                  onTap: () => _onTabSelected(4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String subtext,
    required IconData icon,
    required Color accentColor,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlight ? const Color(0xFFD8F3DC).withAlpha(120) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isHighlight ? const Color(0xFF52B788).withAlpha(80) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B4332).withAlpha(6),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? const Color(0xFF1B4332) : const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, size: 16, color: accentColor),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 10,
                color: isHighlight ? const Color(0xFF2D6A4F) : const Color(0xFF64748B),
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMandiRateItem({
    required String name,
    required String price,
    required String distance,
    required String tag,
    required double progress,
    bool isTop = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isTop ? const Color(0xFFD8F3DC) : const Color(0xFFF1F5F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isTop ? const Color(0xFF1B4332) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    price,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B4332)),
                  ),
                  const Text(' / kg', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ),
              Text(distance, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(isTop ? const Color(0xFF40916C) : const Color(0xFF2D6A4F)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFD8F3DC),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: Color(0xFF1B4332)),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherItem extends StatelessWidget {
  final String label;
  final String value;
  final String note;

  const _WeatherItem({required this.label, required this.value, required this.note});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1B4332))),
        Text(note, style: const TextStyle(fontSize: 9, color: Color(0xFF40916C), fontWeight: FontWeight.bold)),
      ],
    );
  }
}
