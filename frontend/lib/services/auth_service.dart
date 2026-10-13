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
  /// directly from the authoritative 'profiles' database table, falling back to
  /// auth user_metadata if the profiles table is not yet configured.
  Future<String?> getUserRole([String? userId]) async {
    final user = currentUser;
    final uid = userId ?? user?.id;
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
      print('PROFILE LOAD NOTICE: $e');
    }

    // 1. Fallback to auth metadata stored on signup
    if (user != null && user.id == uid && user.userMetadata != null) {
      final metaRole = user.userMetadata!['role'];
      if (metaRole != null && metaRole is String && metaRole.trim().isNotEmpty) {
        final sanitized = metaRole.toLowerCase().trim();
        // Try background creating/healing the profile row if possible
        _trySyncProfile(uid, sanitized, user.userMetadata!['full_name'] as String?, user.email);
        return sanitized;
      }
    }

    // 2. Default to farmer role so user is never locked out
    return AppConstants.roleFarmer;
  }

  /// Attempts to populate profiles table in the background if it exists
  Future<void> _trySyncProfile(String uid, String role, String? fullName, String? email) async {
    try {
      final payload = <String, dynamic>{
        'id': uid,
        'role': role,
      };
      if (fullName != null) payload['full_name'] = fullName;
      if (email != null) payload['email'] = email;
      await _client.from('profiles').upsert(payload);
    } catch (_) {
      // Table may not have insert permissions or not exist yet
    }
  }
}
