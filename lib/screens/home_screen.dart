import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/constant/color_constant.dart';
import 'package:google_doc_clone/models/document_model.dart';
import 'package:google_doc_clone/models/error_model.dart';
import 'package:google_doc_clone/repository/auth.dart';
import 'package:google_doc_clone/repository/document_repository.dart';
import 'package:google_doc_clone/screens/document_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authRepoProvider).signOut();
    ref.read(userRepository.notifier).update((state) => null);
  }

  void createDocument(WidgetRef ref, BuildContext context) async {
    String token = ref.read(userRepository)!.token;
    final nav = Navigator.of(context);
    final snack = ScaffoldMessenger.of(context);

    final errorModel = await ref.read(documentProvider).createDocument(token);

    if (errorModel.data != null) {
      nav.push(
        MaterialPageRoute(
          builder: (context) => DocumentScreen(
            id: errorModel.data.id,
          ),
        ),
      );
    } else {
      snack.showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  void navToDocument(BuildContext context, String documentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentScreen(id: documentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(elevation: 0, backgroundColor: kWhite, actions: [
          IconButton(
            onPressed: () => createDocument(ref, context),
            icon: const Icon(
              Icons.add,
              color: kBlack,
            ),
          ),
          IconButton(
            onPressed: () => signOut(ref),
            icon: const Icon(
              Icons.logout_outlined,
              color: kRed,
            ),
          )
        ]),
        body: FutureBuilder<ErrorModel>(
          future: ref
              .read(documentProvider)
              .getDocument(ref.watch(userRepository)!.token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 600,
                child: ListView.builder(
                    itemCount: snapshot.data?.data?.length ?? 0,
                    itemBuilder: ((context, index) {
                      DocumentModel document = snapshot.data!.data[index];

                      return InkWell(
                        onTap: () => navToDocument(context, document.id),
                        child: SizedBox(
                          height: 50,
                          child: Card(
                            child: Center(
                              child: Text(
                                document.title,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      );
                    })),
              ),
            );
          },
        ));
  }
}
