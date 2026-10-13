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

            final role = roleSnapshot.data ?? AppConstants.roleFarmer;
            switch (role) {
              case AppConstants.roleRetailer:
                return const RetailerHomeScreen();
              case AppConstants.roleAdmin:
                return const AdminHomeScreen();
              case AppConstants.roleFarmer:
              default:
                return const FarmerHomeScreen();
            }
          },
        );
      },
    );
  }
}
