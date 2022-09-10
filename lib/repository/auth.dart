import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/constant/url_constant.dart';
import 'package:google_doc_clone/models/error_model.dart';
import 'package:google_doc_clone/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client()),
);

final userRepository = StateProvider<UserModel?>(((ref) => null));

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
  })  : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> singInUser() async {
    ErrorModel errorModel =
        ErrorModel(error: "Something unexpected error occurred", data: null);
    try {
      final user = await _googleSignIn.signIn();

      if (user != null) {
        final userAccount = UserModel(
            name: user.displayName!,
            email: user.email,
            uid: "",
            token: "",
            profilePic: user.photoUrl!);
        Response? response;
        try {
          response = await _client.post(
            Uri.parse(UrlConstant.signUp),
            body: userAccount.toJson(),
            headers: {
              "Content-Type": "application/json;charset=UTF-8",
            },
          );
        } catch (e) {
          print("Something Went Wrong");
          print(e);
        }
        switch (response?.statusCode) {
          case 200:
            final userData = userAccount.copyWith(
              uid: jsonDecode(response!.body)['user']['_id'],
            );
            errorModel = ErrorModel(error: "Success", data: userData);
            break;
          default:
            errorModel = ErrorModel(error: "Something Went Wrong", data: null);
        }
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    return errorModel;
  }
}
