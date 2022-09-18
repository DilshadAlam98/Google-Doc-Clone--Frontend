import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/constant/assets_constants.dart';
import 'package:google_doc_clone/constant/color_constant.dart';
import 'package:google_doc_clone/repository/auth.dart';
import 'package:google_doc_clone/screens/home_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void singInGoogle(WidgetRef ref, BuildContext context) async {
    final errorModel = await ref.read(authRepoProvider).singInUser();
    final sMessenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    if (errorModel.error == null) {
      ref.read(userRepository.notifier).update((state) => errorModel.data);
      nav.push(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      sMessenger.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 40),
              padding: const EdgeInsets.all(10),
              elevation: 10,
              primary: kWhite),
          onPressed: () {
            singInGoogle(ref, context);
          },
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
