import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_doc_clone/constant/url_constant.dart';
import 'package:google_doc_clone/models/document_model.dart';
import 'package:google_doc_clone/models/error_model.dart';
import 'package:http/http.dart';

final documentProvider =
    Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;
  DocumentRepository({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel errorModel = ErrorModel(
      error: "Some unexpected error occurred",
      data: null,
    );

    try {
      final res = await _client.post(Uri.parse(UrlConstant.createDocument),
          headers: {
            "Content-Type": "application/json;charset=UTF-8",
            "x-auth-token": token
          },
          body:
              jsonEncode({'createdAt': DateTime.now().microsecondsSinceEpoch}));

      switch (res.statusCode) {
        case 200:
          errorModel = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          errorModel = ErrorModel(
            error: res.body,
            data: null,
          );
      }
    } catch (e) {
      print(e);
    }
    return errorModel;
  }

  Future<ErrorModel> getDocument(String token) async {
    ErrorModel errorModel = ErrorModel(
      error: "Some unexpected error occurred",
      data: null,
    );

    try {
      final res = await _client.get(
        Uri.parse(UrlConstant.getDocument),
        headers: {
          "Content-Type": "application/json;charset=UTF-8",
          "x-auth-token": token
        },
      );

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> documents = [];

          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            documents.add(
              DocumentModel.fromJson(
                jsonEncode(jsonDecode(res.body)[i]),
              ),
            );
          }
          errorModel = ErrorModel(
            error: null,
            data: documents,
          );
          break;
        default:
          errorModel = ErrorModel(
            error: res.body,
            data: null,
          );
      }
    } catch (e) {
      print(e);
    }
    return errorModel;
  }
}
