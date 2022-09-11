import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/models/error_model.dart';
import 'package:google_doc_clone/repository/auth.dart';
import 'package:google_doc_clone/screens/home_screen.dart';
import 'package:google_doc_clone/screens/login_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepoProvider).getUserData();

    if (errorModel != null && errorModel!.data != null) {
      ref.read(userRepository.notifier).update((state) => errorModel!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userRepository);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
