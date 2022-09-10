import 'package:flutter/material.dart';
import 'package:google_doc_clone/constant/assets_constants.dart';
import 'package:google_doc_clone/constant/color_constant.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 40),
              padding: const EdgeInsets.all(10),
              elevation: 10,
              primary: kWhite),
          onPressed: () {},
          icon: Image.asset(
            AssetConstants.google,
            height: 20,
          ),
          label: const Text(
            "Sign In ",
            style: TextStyle(color: kBlack),
          ),
        ),
      ),
    );
  }
}
