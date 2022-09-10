// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod/riverpod.dart';

// final authRepoProvider = Provider(((ref) => AuthRepository())

final authRepoProvider = Provider(
  (ref) =>  AuthRepository(
      googleSignIn: GoogleSignIn(),
    ),
);

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  AuthRepository({
    required GoogleSignIn googleSignIn,
  }) : _googleSignIn = googleSignIn;

  void singInUser() async {
    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        print(user.toString());
      }
    } catch (e) {
      print("ERROR IN GOOGLE SING IN \n $e");
    }
  }
}
