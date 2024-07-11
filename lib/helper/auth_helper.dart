import 'package:berita_app/auth/signin_page.dart';
import 'package:berita_app/main.dart';
import 'package:berita_app/user/list_news.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthHelper {
  static Future<void> signIn(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is badly formatted.';
          break;
        case 'user-disabled':
          message = 'The user account has been disabled by an administrator.';
          break;
        case 'user-not-found':
          message = 'There is no user corresponding to the given email.';
          break;
        case 'wrong-password':
          message =
              'The password is invalid or the user does not have a password.';
          break;
        case 'invalid-credential':
          message = 'The supplied auth credential is malformed or has expired.';
          break;
        default:
          message = 'An undefined error happened.';
      }

      print(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  // Method untuk sign out
  static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Refresh the app by navigating to the login page and clearing the navigation stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $e')),
      );
    }
  }

  static Future<String?> getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc['role'];
    }
    return null;
  }
}
