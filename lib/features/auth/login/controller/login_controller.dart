import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:home_haven/core/util/export.dart';

class LoginController extends GetxController {
  bool hidenPassword = true;
  void showPassword() {
    hidenPassword = !hidenPassword;
    update();
  }

  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;

  String adminEmail = "sabbirsamolla51@gmail.com";

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      update();

      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      user = credential.user;

      if (user != null) {
        await user!.reload();
        user = _auth.currentUser;

        if (user!.emailVerified) {
          try {
            DocumentSnapshot doc =
                await _firestore.collection('auth').doc(user!.uid).get();

            if (doc.exists) {
              Map<String, dynamic> userData =
                  doc.data() as Map<String, dynamic>;
              String role = userData['role'] ?? 'customer';

              if (role == "admin" && email.trim().toLowerCase() != adminEmail) {
                ScaffoldMessenger.of(Get.context!).showSnackBar(
                  SnackBar(
                    content: Text("Only $adminEmail can login as Admin!"),
                  ),
                );

                await _auth.signOut();
                return;
              }

              ScaffoldMessenger.of(Get.context!).showSnackBar(
                SnackBar(
                  content: Text('Login Successfully as $role'),
                ),
              );

              if (role == "admin") {
                Get.offAllNamed(RouterConstant.adminDashboard);
              } else {
                Get.offAllNamed(RouterConstant.mainScreen);
              }
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar('Success', 'Login Successfully');
              });
              Get.offAllNamed(RouterConstant.mainScreen);
            }
          } catch (firestoreError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.snackbar('Success', 'Login Successfully');
            });
            Get.offAllNamed(RouterConstant.mainScreen);
          }
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Error', 'Please verify your email');
          });
          await _auth.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        default:
          errorMessage = e.message ?? 'Something went wrong';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', errorMessage);
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'An unexpected error occurred');
      });
    } finally {
      isLoading = false;
      update();
    }
  }

  //Google sign in
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogleForceAccountPicker() async {
    try {
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        // Same logic as above for user handling
        final doc = await FirebaseFirestore.instance
            .collection('auth')
            .doc(user.uid)
            .get();

        if (!doc.exists) {
          await FirebaseFirestore.instance
              .collection('auth')
              .doc(user.uid)
              .set({
            'uid': user.uid,
            'name': user.displayName ?? 'No Name',
            'email': user.email,
            'photoURL': user.photoURL,
            'provider': 'google',
            'role': 'customer',
            'createdAt': DateTime.now(),
            'emailVerified': true,
          });
        }

        String role = doc.exists ? doc['role'] ?? 'customer' : 'customer';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Success',
            'Google login successful! Welcome ${user.displayName ?? 'User'}',
            snackPosition: SnackPosition.TOP,
            duration: Duration(seconds: 3),
          );
        });

        if (role == 'admin') {
          Get.offAllNamed(RouterConstant.adminDashboard);
        } else {
          Get.offAllNamed(RouterConstant.mainScreen);
        }
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'Google sign-in failed: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 4),
        );
      });
    }
  }
}
