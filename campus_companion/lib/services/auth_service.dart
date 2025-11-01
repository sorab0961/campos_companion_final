import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = supabase;
  String? _currentUserRole;

  String? get currentUserRole => _currentUserRole;

  Future<void> signUp(
    String email,
    String password,
    String role, {
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role,
          'full_name': fullName ?? email.split('@').first.replaceAll('.', ' '),
          'avatar_url':
              'https://ui-avatars.com/api/?background=6C63FF&color=fff&name=${fullName?.isNotEmpty == true ? fullName![0] : email[0]}',
        },
      );
      if (response.user != null) {
        _currentUserRole = role;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      _currentUserRole = response.user?.userMetadata?['role'] as String?;
      if (_currentUserRole == null) {
        await fetchAndSetUserRole(); // Attempt to fetch role if not in metadata
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _currentUserRole = null;
    notifyListeners();
  }

  User? getCurrentUser() => _client.auth.currentUser;

  Future<String?> getUserRole(String userId) async {
    try {
      final user = getCurrentUser();
      if (user != null && user.id == userId) {
        if (user.userMetadata?['role'] != null) {
          return user.userMetadata!['role'] as String;
        }

        // If role is not in metadata, check the profiles table
        final response = await _client
            .from('profiles')
            .select('role')
            .eq('id', userId)
            .single();

        if (response != null && response['role'] != null) {
          // Update user metadata with the role
          await _client.auth.updateUser(
            UserAttributes(data: {'role': response['role']}),
          );
          return response['role'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<void> fetchAndSetUserRole() async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        _currentUserRole = await getUserRole(user.id);
        if (_currentUserRole != null) {
          notifyListeners();
        } else {
          throw Exception('Could not determine user role');
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch user role: $e');
    }
  }

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;
}
