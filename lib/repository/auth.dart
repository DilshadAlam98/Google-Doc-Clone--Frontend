import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/constant/url_constant.dart';
import 'package:google_doc_clone/models/error_model.dart';
import 'package:google_doc_clone/models/user_model.dart';
import 'package:google_doc_clone/repository/local_storage_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepoProvider = Provider(
  (ref) => AuthRepository(
    googleSignIn: GoogleSignIn(),
    client: Client(),
    localStorage: LocalStorage(),
  ),
);

final userRepository = StateProvider<UserModel?>(((ref) => null));

class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorage _localStorage;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorage localStorage,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorage = localStorage;

  Future<ErrorModel> singInUser() async {
    ErrorModel? errorModel =
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
          errorModel = ErrorModel(error: e.toString(), data: null);
        }
        switch (response?.statusCode) {
          case 200:
            final userData = userAccount.copyWith(
              uid: jsonDecode(response!.body)['user']['_id'],
              token: jsonDecode(response.body)['token'],
            );
            print(" Token :  ${userData.token}");
            errorModel = ErrorModel(error: null, data: userData);
            _localStorage.setToken(userData.token);
            break;
          default:
        }
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    return errorModel;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel errorModel =
        ErrorModel(error: "Something unexpected error occurred", data: null);
    Response? response;
    String? token = await _localStorage.getToken();

    try {
      if (token != null) {
        response = await _client.get(
          Uri.parse(UrlConstant.getUsers),
          headers: {
            "Content-Type": "application/json;charset=UTF-8",
            "x-auth-token": token
          },
        );
      }
    } catch (e) {
      errorModel = ErrorModel(error: e.toString(), data: null);
    }
    switch (response?.statusCode) {
      case 200:
        final newUser = UserModel.fromJson(
          jsonEncode(
            jsonDecode(response!.body)['user'],
          ),
        ).copyWith(token: token);
        errorModel = ErrorModel(error: null, data: newUser);
        _localStorage.setToken(newUser.token);
        break;
      default:
    }
    return errorModel;
  }

  void signOut() {
    _googleSignIn.signOut();
    _localStorage.clearPref();
  }
}
