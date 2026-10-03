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
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff087f72)),
      scaffoldBackgroundColor: const Color(0xfff4f7fa),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xfff4f7fa),
        foregroundColor: Color(0xff183b3b),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xff183b3b),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xffe4ebef)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xff087f72),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xffd9f1eb),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffd6e2e6)),
        ),
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
