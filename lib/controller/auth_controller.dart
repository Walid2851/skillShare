import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AuthController extends GetxController {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = Uuid();

  final RxBool isLoading = false.obs;
  final Rx<firebase.User?> user = Rx<firebase.User?>(null);

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      if (!GetUtils.isEmail(email)) throw 'Invalid email format';
      if (password.length < 6) throw 'Password must be at least 6 characters';
      if (username.isEmpty) throw 'Username is required';

      // Check username uniqueness
      final usernameCheck = await _supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (usernameCheck != null) throw 'Username already taken';

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) throw 'Failed to create user';

      // Use UUID v4 for Supabase id
      await _supabase.from('users').insert({
        'id': _uuid.v4(),
        'firebase_uid': userCredential.user!.uid,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'phone': phone,
        'created_at': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        'Success',
        'Account created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed('/home');

    } catch (e) {
      String errorMessage = 'An error occurred';

      if (e is firebase.FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Email is already registered';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format';
            break;
          default:
            errorMessage = e.message ?? 'Authentication failed';
        }
      } else if (e is PostgrestException) {
        if (e.message.contains('users_email_key')) {
          errorMessage = 'Email already registered';
        } else if (e.message.contains('users_username_key')) {
          errorMessage = 'Username already taken';
        } else {
          errorMessage = 'Database error: ${e.message}';
        }
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;

      if (!GetUtils.isEmail(email)) throw 'Invalid email format';

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) throw 'Login failed';

      final userData = await _supabase
          .from('users')
          .select()
          .eq('firebase_uid', userCredential.user!.uid)
          .single();

      Get.snackbar(
        'Success',
        'Welcome back, ${(userData as Map)['first_name']}!',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAllNamed('/home');

    } catch (e) {
      String errorMessage = 'An error occurred';

      if (e is firebase.FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled';
            break;
          default:
            errorMessage = e.message ?? 'Authentication failed';
        }
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userData = await _supabase
            .from('users')
            .select('id')
            .eq('firebase_uid', currentUser.uid)
            .single();

        await _supabase.from('users').delete().eq('id', userData['id']);
        await currentUser.delete();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      isLoading.value = false;
    }
  }
}