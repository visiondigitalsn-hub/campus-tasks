import 'package:flutter/material.dart';
import '../api.dart';

class AuthScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onConnected;
  const AuthScreen({super.key, required this.api, required this.onConnected});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  bool register = false, busy = false, obscure = true;
  String? error;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) {
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.authenticate(register, {
        'name': name.text.trim(),
        'email': email.text.trim(),
        'password': password.text,
      });
      if (mounted) widget.onConnected();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Color(0xff245b51),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CampusTasks',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tes cours. Tes échéances. Ton organisation.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    register ? 'Créer mon compte' : 'Heureux de te revoir',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  if (register) ...[
                    TextFormField(
                      controller: name,
                      maxLength: 100,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Indique ton nom.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    maxLength: 254,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) =>
                        v == null ||
                            !RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(v.trim())
                        ? 'Indique un e-mail valide.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: password,
                    obscureText: obscure,
                    maxLength: 72,
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty || (register && v.length < 8)
                        ? 'Au moins 8 caractères pour un nouveau compte.'
                        : null,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: busy ? null : submit,
                    child: busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(register ? 'Créer mon compte' : 'Se connecter'),
                  ),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() {
                            register = !register;
                            error = null;
                          }),
                    child: Text(
                      register ? 'J’ai déjà un compte' : 'Créer un compte',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
