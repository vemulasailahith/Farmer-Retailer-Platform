import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../widgets/farmer_drawer.dart';
import '../../widgets/language_selector.dart';
import 'farmer_input_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final AuthService _authService = AuthService();
  bool _isSigningOut = false;

  Future<void> _confirmSignOut() async {
    if (_isSigningOut) return;

    final l10n = AppLocalizations.of(context)!;
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.logout, color: Color(0xFF2E7D32), size: 32),
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
              backgroundColor: const Color(0xFF2E7D32),
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
      await _authService.signOut();
      // AuthGate automatically listens to authStateChanges and redirects to Login
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const FarmerDrawer(),
      appBar: AppBar(
        // LEFT: Hamburger menu icon (first control on the left)
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: l10n.menuTooltip,
            onPressed: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
          ),
        ),
        // CENTER: Responsive Title
        title: Text(
          l10n.farmerDashboard,
          overflow: TextOverflow.ellipsis,
        ),
        // RIGHT: Language Selector & Sign Out Button
        actions: [
          const LanguageSelector(),
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final isWide = screenWidth >= 600;

              if (isWide) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton.icon(
                    onPressed: _isSigningOut ? null : () => _confirmSignOut(),
                    icon: _isSigningOut
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.logout, color: Colors.white, size: 20),
                    label: Text(
                      l10n.signOut,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                );
              }

              return IconButton(
                icon: _isSigningOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.logout),
                tooltip: l10n.signOut,
                onPressed: _isSigningOut ? null : () => _confirmSignOut(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.agriculture,
                size: 72,
                color: Color(0xFF2E7D32),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.farmerDashboard,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.welcomeFarmerSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FarmerInputScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                ),
                icon: const Icon(Icons.add_chart),
                label: Text(
                  l10n.startCropRecommendation,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isSigningOut ? null : () => _confirmSignOut(),
                icon: const Icon(Icons.logout),
                label: Text(l10n.signOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
