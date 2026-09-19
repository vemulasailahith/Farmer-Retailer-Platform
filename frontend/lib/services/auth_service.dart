import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Returns the currently authenticated Supabase user or null.
  User? get currentUser => _client.auth.currentUser;

  /// Returns the current active session or null.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream of authentication state events (signedIn, signedOut, tokenRefreshed, etc.).
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up a new user with email, password, full name, and role.
  /// Only 'farmer' and 'retailer' are permitted for self-registration.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final sanitizedRole = role.toLowerCase().trim();

    // Security check: strictly reject any unauthorized or admin registration attempt
    if (!AppConstants.publicRegistrationRoles.contains(sanitizedRole)) {
      throw ArgumentError(
        'Invalid registration role "$role". Allowed roles are: '
        '${AppConstants.publicRegistrationRoles.join(", ")}.',
      );
    }

    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'role': sanitizedRole,
      },
    );

    return response;
  }

  /// Sign in an existing user with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user session.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Retrieves the role of the specified user (or currentUser if not provided)
  /// directly from the authoritative 'profiles' database table.
  Future<String?> getUserRole([String? userId]) async {
    final uid = userId ?? currentUser?.id;
    if (uid == null) return null;

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', uid)
          .maybeSingle();

      if (response != null && response['role'] != null) {
        return (response['role'] as String).toLowerCase().trim();
      }
    } catch (e) {
      // ignore: avoid_print
      print('PROFILE LOAD ERROR: $e');
    }

    return null;
  }
}
