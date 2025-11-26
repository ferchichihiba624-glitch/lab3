// lib/services/auth_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../config/appwrite_config.dart';

class AuthService {
  // Reference to Appwrite Account service
  late final Account account;

  AuthService() {
    // Initialize the Account service with our Appwrite client
    account = Account(AppwriteConfig.client);
  }

  // Register a new user
  Future<Session> createAccount(String email, String password, String name) async {
    try {
      // Create a new account using Appwrite SDK
      final user = await account.create(
        userId: ID.unique(), // Generate a unique ID
        email: email,
        password: password,
        name: name,
      );

      // If account creation is successful, automatically log the user in
      if (user.$id.isNotEmpty) {
        return login(email, password);
      } else {
        throw Exception('Failed to create account');
      }
    } catch (error) {
      print('Error creating account: $error');
      rethrow; // Re-throw error for handling in UI
    }
  }

  // Log in an existing user
  Future<Session> login(String email, String password) async {
    try {
      // Create an email session using Appwrite SDK
      return await account.createEmailSession(
        email: email,
        password: password,
      );
    } catch (error) {
      print('Error logging in: $error');
      rethrow;
    }
  }

  // Get current session/user
  Future<User?> getCurrentUser() async {
    try {
      // Get current account information
      return await account.get();
    } catch (error) {
      print('Error getting current user: $error');
      return null; // Return null if no user is logged in
    }
  }

  // Log out the current user
  Future<void> logout() async {
    try {
      // Delete the current session
      await account.deleteSession(sessionId: 'current');
    } catch (error) {
      print('Error logging out: $error');
      rethrow;
    }
  }
}