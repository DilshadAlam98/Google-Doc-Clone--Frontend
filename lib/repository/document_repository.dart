import 'dart:convert';

import 'package:flutter/material.dart';
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
      errorModel = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return errorModel;
  }

  void updateDocument({
    required String token,
    required String id,
    required String title,
    required BuildContext context,
  }) async {
    try {
      final res = await _client.post(Uri.parse(UrlConstant.updateDocument),
          headers: {
            "Content-Type": "application/json;charset=UTF-8",
            "x-auth-token": token
          },
          body: jsonEncode({
            'title': title,
            'id': id,
          }));

      switch (res.statusCode) {
        case 200:
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Document Updated")));
          break;
        default:
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Failed to Update")));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel errorModel = ErrorModel(
      error: "Some unexpected error occurred",
      data: null,
    );

    try {
      final res = await _client.get(
        Uri.parse(UrlConstant.getDocumentById + id),
        headers: {
          "Content-Type": "application/json;charset=UTF-8",
          "x-auth-token": token
        },
      );

      switch (res.statusCode) {
        case 200:
          errorModel = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          throw 'This Document is not exist. Please create new one';
      }
    } catch (e) {
      errorModel = ErrorModel(
        error: e.toString(),
        data: null,
      );
    }
    return errorModel;
  }
}
