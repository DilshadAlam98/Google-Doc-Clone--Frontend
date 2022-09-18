import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/constant/assets_constants.dart';
import 'package:google_doc_clone/constant/color_constant.dart';
import 'package:google_doc_clone/models/document_model.dart';
import 'package:google_doc_clone/models/error_model.dart';
import 'package:google_doc_clone/repository/auth.dart';
import 'package:google_doc_clone/repository/document_repository.dart';
import 'package:google_doc_clone/repository/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);
  final String id;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final TextEditingController _titleController =
      TextEditingController(text: "Untitled Document");

  quill.QuillController? _controller;

  ErrorModel? errorModel;

  SocketRepository socketRepository = SocketRepository();
  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();
    socketRepository.changeListener((data) {
      _controller?.compose(
        quill.Delta.fromJson(data['delta']),
        _controller?.selection ?? const TextSelection.collapsed(offset: 1),
        quill.ChangeSource.REMOTE,
      );
    });
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller?.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  fetchDocumentData() async {
    errorModel = await ref
        .read(documentProvider)
        .getDocumentById(ref.read(userRepository)!.token, widget.id);

    if (errorModel!.data != null) {
      _titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(errorModel!.data.content),
                ),
          selection: const TextSelection.collapsed(offset: 0));
      setState(() {});
    }
    _controller?.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.item2,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void updateDocument(WidgetRef ref, String title) async {
    ref.read(documentProvider).updateDocument(
        token: ref.read(userRepository)!.token,
        id: widget.id,
        title: title,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kWhite,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.lock,
                  size: 16,
                ),
                label: const Text("Share"),
              ),
            )
          ],
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset(
                    AssetConstants.doc,
                    height: 40,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    onSubmitted: (value) {
                      updateDocument(ref, value);
                    },
                    controller: _titleController,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        contentPadding: EdgeInsets.only(left: 8)),
                  ),
                )
              ],
            ),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade800,
                    width: 0.1,
                  ),
                ),
              )),
        ),
        body: Column(
          children: [
            quill.QuillToolbar.basic(controller: _controller!),
            Expanded(
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: quill.QuillEditor.basic(
                    controller: _controller!,
                    readOnly: false, // true for view only mode
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
