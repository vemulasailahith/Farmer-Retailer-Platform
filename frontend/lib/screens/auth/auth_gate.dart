import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_indicator.dart';
import '../admin/admin_home_screen.dart';
import '../farmer/farmer_home_screen.dart';
import '../retailer/retailer_home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<AuthState>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        final session = _authService.currentSession;

        // If no active session, present the login screen
        if (session == null) {
          return const LoginScreen();
        }

        // Active session exists: fetch authoritative role from the database profiles table
        final userId = session.user.id;

        return FutureBuilder<String?>(
          future: _authService.getUserRole(userId),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: LoadingIndicator(
                  message: l10n?.verifyingPermissions ?? 'Verifying permissions...',
                ),
              );
            }

            if (roleSnapshot.hasError || roleSnapshot.data == null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.profileError ?? 'Profile Error',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.profileErrorMessage ??
                              'Unable to load your user profile and role from the database.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _authService.signOut();
                          },
                          icon: const Icon(Icons.logout),
                          label: Text(l10n?.returnToLogin ?? 'Return to Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final role = roleSnapshot.data!;
            switch (role) {
              case AppConstants.roleFarmer:
                return const FarmerHomeScreen();
              case AppConstants.roleRetailer:
                return const RetailerHomeScreen();
              case AppConstants.roleAdmin:
                return const AdminHomeScreen();
              default:
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.block,
                            color: Colors.redAccent,
                            size: 56,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Access Restricted ($role)',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your account has an unassigned or unsupported role.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await _authService.signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(l10n?.signOut ?? 'Sign Out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}
