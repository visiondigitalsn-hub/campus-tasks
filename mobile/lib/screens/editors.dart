import 'package:flutter/material.dart';
import '../api.dart';
import 'home_screen.dart';

class EditorScreen extends StatefulWidget {
  final Api api;
  final bool task;
  final List<dynamic> subjects;
  final Map<String, dynamic>? item;
  const EditorScreen({
    super.key,
    required this.api,
    required this.task,
    required this.subjects,
    this.item,
  });
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final form = GlobalKey<FormState>();
  late final TextEditingController title, description;
  late DateTime date;
  int? subjectId;
  String priority = 'MEDIUM', status = 'TODO';
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final item = widget.item;
    title = TextEditingController(
      text: item?[widget.task ? 'title' : 'name'] as String? ?? '',
    );
    description = TextEditingController(
      text: item?['description'] as String? ?? '',
    );
    date = item?['dueDate'] != null
        ? DateTime.parse(item!['dueDate'] as String)
        : DateUtils.dateOnly(DateTime.now());
    subjectId =
        item?['subjectId'] as int? ??
        (widget.subjects.isEmpty ? null : widget.subjects.first['id'] as int);
    priority = item?['priority'] as String? ?? 'MEDIUM';
    status = item?['status'] as String? ?? 'TODO';
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    final body = <String, dynamic>{
      widget.task ? 'title' : 'name': title.text.trim(),
      'description': description.text.trim(),
    };
    if (widget.task) {
      body.addAll({
        'subjectId': subjectId,
        'dueDate': date.toIso8601String().substring(0, 10),
        'priority': priority,
        'status': status,
      });
    }
    try {
      await widget.api.request(
        widget.item == null ? 'POST' : 'PUT',
        '/${widget.task ? 'tasks' : 'subjects'}${widget.item == null ? '' : '/${widget.item!['id']}'}',
        body,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        '${widget.item == null ? 'Ajouter' : 'Modifier'} une ${widget.task ? 'tâche' : 'matière'}',
      ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: title,
              maxLength: widget.task ? 150 : 100,
              decoration: InputDecoration(
                labelText: widget.task ? 'Titre' : 'Nom de la matière',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Ce champ est obligatoire.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: description,
              maxLines: 4,
              maxLength: widget.task ? 4000 : 2000,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            if (widget.task) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: subjectId,
                decoration: const InputDecoration(labelText: 'Matière'),
                items: widget.subjects
                    .map(
                      (s) => DropdownMenuItem<int>(
                        value: s['id'] as int,
                        child: Text(s['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: busy ? null : (v) => setState(() => subjectId = v),
                validator: (v) => v == null ? 'Choisis une matière.' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  'Date limite : ${date.toIso8601String().substring(0, 10)}',
                ),
                onPressed: busy
                    ? null
                    : () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2200),
                        );
                        if (picked != null && mounted) {
                          setState(() => date = picked);
                        }
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: const InputDecoration(labelText: 'Priorité'),
                items: priorityLabels.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: busy ? null : (v) => setState(() => priority = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: statusLabels.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: busy ? null : (v) => setState(() => status = v!),
              ),
            ],
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : save,
              child: Text(busy ? 'Enregistrement…' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    ),
  );
}
