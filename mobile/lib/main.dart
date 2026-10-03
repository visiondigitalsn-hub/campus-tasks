import 'package:flutter/material.dart';
import 'api.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() => runApp(CampusTasksApp(api: Api()));

class CampusTasksApp extends StatelessWidget {
  final Api api;
  const CampusTasksApp({super.key, required this.api});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'CampusTasks',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff245b51)),
      scaffoldBackgroundColor: const Color(0xfff5f7f4),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
    home: SessionGate(api: api),
  );
}

class SessionGate extends StatefulWidget {
  final Api api;
  const SessionGate({super.key, required this.api});
  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  bool ready = false;
  String? error;
  @override
  void initState() {
    super.initState();
    restore();
  }

  Future<void> restore() async {
    try {
      await widget.api.restore();
    } catch (_) {
      error = 'Impossible de lire la session enregistrée.';
    }
    if (mounted) setState(() => ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error!),
              TextButton(
                onPressed: () {
                  setState(() {
                    error = null;
                    ready = false;
                  });
                  restore();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (widget.api.token == null) {
      return AuthScreen(api: widget.api, onConnected: () => setState(() {}));
    }
    return HomeScreen(api: widget.api, onDisconnected: () => setState(() {}));
  }
}
