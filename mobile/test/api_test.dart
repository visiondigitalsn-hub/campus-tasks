import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campus_tasks/api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('Login persiste le jeton et une nouvelle session le restaure', () async {
    final api = Api(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/auth/login');
        expect(jsonDecode(request.body)['email'], 'awa@example.com');
        return http.Response('{"token":"session-test"}', 200);
      }),
    );
    await api.authenticate(false, {
      'email': 'awa@example.com',
      'password': 'Campus123!',
    });
    expect(api.token, 'session-test');
    final restored = Api();
    await restored.restore();
    expect(restored.token, 'session-test');
  });

  test('Bearer envoyé et jeton expiré effacé sur 401', () async {
    FlutterSecureStorage.setMockInitialValues({'token': 'expired'});
    final api = Api(
      client: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer expired');
        return http.Response('{"message":"Veuillez vous connecter."}', 401);
      }),
    );
    await api.restore();
    await expectLater(
      api.request('GET', '/subjects'),
      throwsA(isA<ApiException>().having((e) => e.status, 'status', 401)),
    );
    expect(api.token, isNull);
    expect(await api.storage.read(key: 'token'), isNull);
  });

  test(
    'Déconnexion efface la session locale même si le serveur échoue',
    () async {
      FlutterSecureStorage.setMockInitialValues({'token': 'old'});
      final api = Api(
        client: MockClient(
          (request) async => http.Response('{"message":"Indisponible"}', 503),
        ),
      );
      await api.restore();
      await expectLater(api.logout(), throwsA(isA<ApiException>()));
      expect(api.token, isNull);
      expect(await api.storage.read(key: 'token'), isNull);
    },
  );

  test('Les messages accentués et les réponses vides sont compris', () async {
    final api = Api(
      client: MockClient(
        (request) async => http.Response.bytes(
          utf8.encode('{"message":"Matière utilisée."}'),
          409,
        ),
      ),
    );
    await expectLater(
      api.request('DELETE', '/subjects/1'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Matière utilisée.',
        ),
      ),
    );
    final empty = Api(
      client: MockClient((request) async => http.Response('', 204)),
    );
    expect(await empty.request('DELETE', '/tasks/1'), isNull);
  });
}
