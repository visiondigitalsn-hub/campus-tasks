import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class Api {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080/api/v1',
  );
  final http.Client client;
  final FlutterSecureStorage storage;
  String? token;
  Api({http.Client? client, FlutterSecureStorage? storage})
    : client = client ?? http.Client(),
      storage = storage ?? const FlutterSecureStorage();
  Future<void> restore() async {
    token = await storage.read(key: 'token');
  }

  Future<void> authenticate(bool register, Map<String, dynamic> body) async {
    final data = await request(
      'POST',
      '/auth/${register ? 'register' : 'login'}',
      body,
    );
    final value = data['token'] as String;
    await storage.write(key: 'token', value: value);
    token = value;
  }

  Future<void> logout() async {
    try {
      await request('POST', '/auth/logout');
    } finally {
      token = null;
      await storage.delete(key: 'token');
    }
  }

  Future<dynamic> request(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final uri = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final response = await http.Response.fromStream(
        await client.send(request).timeout(const Duration(seconds: 20)),
      ).timeout(const Duration(seconds: 20));
      final data = response.body.isEmpty
          ? null
          : jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 400) {
        if (response.statusCode == 401 && token != null) {
          token = null;
          await storage.delete(key: 'token');
        }
        throw ApiException(
          data is Map
              ? data['message'] as String? ?? 'Erreur serveur.'
              : 'Erreur serveur.',
          response.statusCode,
        );
      }
      return data;
    } on TimeoutException {
      throw const ApiException('Le serveur ne répond pas. Réessayez.');
    } on SocketException {
      throw const ApiException(
        'Connexion impossible. Vérifiez Internet et l’adresse du serveur.',
      );
    } on http.ClientException {
      throw const ApiException('Connexion impossible avec le serveur.');
    } on FormatException {
      throw const ApiException('Réponse du serveur invalide.');
    }
  }
}
