import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_tasks/api.dart';
import 'package:campus_tasks/main.dart';

class MemoryApi extends Api {
  @override
  Future<void> restore() async {
    token = null;
  }
}

void main() {
  testWidgets('Connexion et inscription disponibles', (tester) async {
    await tester.pumpWidget(CampusTasksApp(api: MemoryApi()));
    await tester.pumpAndSettle();
    expect(find.text('CampusTasks'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    await tester.tap(find.text('Créer un compte'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'Nom'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Créer mon compte'));
    await tester.pumpAndSettle();
    expect(find.text('Indique ton nom.'), findsOneWidget);
  });
}
