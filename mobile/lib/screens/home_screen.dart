import 'package:flutter/material.dart';
import '../api.dart';
import 'editors.dart';

const statusLabels = {
  'TODO': 'À faire',
  'IN_PROGRESS': 'En cours',
  'DONE': 'Terminée',
};
const priorityLabels = {'LOW': 'Basse', 'MEDIUM': 'Moyenne', 'HIGH': 'Haute'};

class HomeScreen extends StatefulWidget {
  final Api api;
  final VoidCallback onDisconnected;
  const HomeScreen({
    super.key,
    required this.api,
    required this.onDisconnected,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  bool loading = true, loggingOut = false;
  String? error, status;
  int? subjectId;
  bool descending = false;
  List<dynamic> subjects = [], tasks = [];
  Map<String, dynamic> dashboard = {};
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final query = <String, String>{'sort': descending ? 'desc' : 'asc'};
      if (status != null) query['status'] = status!;
      if (subjectId != null) query['subjectId'] = '$subjectId';
      final data = await Future.wait([
        widget.api.request('GET', '/subjects'),
        widget.api.request(
          'GET',
          '/tasks?${Uri(queryParameters: query).query}',
        ),
        widget.api.request('GET', '/dashboard'),
      ]);
      if (mounted) {
        setState(() {
          subjects = data[0] as List;
          tasks = data[1] as List;
          dashboard = Map<String, dynamic>.from(data[2]);
        });
      }
    } catch (e) {
      if (widget.api.token == null) {
        widget.onDisconnected();
        return;
      }
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> logout() async {
    setState(() => loggingOut = true);
    try {
      await widget.api.logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Session locale effacée. $e')));
      }
    } finally {
      if (mounted) widget.onDisconnected();
    }
  }

  Future<void> edit(bool task, [Map<String, dynamic>? item]) async {
    if (task && subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoute une matière avant de créer une tâche.'),
        ),
      );
      setState(() => tab = 2);
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          api: widget.api,
          task: task,
          subjects: subjects,
          item: item,
        ),
      ),
    );
    if (!mounted) return;
    if (widget.api.token == null) {
      widget.onDisconnected();
      return;
    }
    if (changed == true) await load();
  }

  Future<void> remove(bool task, Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cet élément ?'),
        content: Text(
          task
              ? item['title'] as String
              : 'Les matières contenant des tâches ne peuvent pas être supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await widget.api.request(
        'DELETE',
        '/${task ? 'tasks' : 'subjects'}/${item['id']}',
      );
      if (!task && subjectId == item['id']) subjectId = null;
      if (mounted) await load();
    } catch (e) {
      if (widget.api.token == null) {
        widget.onDisconnected();
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget taskCard(dynamic value) {
    final t = Map<String, dynamic>.from(value as Map);
    final late =
        t['status'] != 'DONE' &&
        DateTime.parse(
          t['dueDate'] as String,
        ).isBefore(DateUtils.dateOnly(DateTime.now().toUtc()));
    return Card(
      child: ListTile(
        leading: Icon(
          t['status'] == 'DONE'
              ? Icons.check_circle_outline
              : late
              ? Icons.warning_amber
              : Icons.assignment_outlined,
          color: late ? Colors.red.shade700 : null,
        ),
        title: Text(t['title'] as String),
        subtitle: Text(
          '${t['subjectName']} · ${t['dueDate']}\n${statusLabels[t['status']]} · Priorité ${priorityLabels[t['priority']]}${late ? ' · En retard' : ''}',
        ),
        isThreeLine: true,
        onTap: () => edit(true, t),
        trailing: IconButton(
          tooltip: 'Supprimer la tâche',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => remove(true, t),
        ),
      ),
    );
  }

  Widget dashboardView() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        'Une vue claire sur ta semaine',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final entry in {
            'todo': 'À faire',
            'inProgress': 'En cours',
            'done': 'Terminées',
            'overdue': 'En retard',
          }.entries)
            SizedBox(
              width: 155,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dashboard[entry.key] ?? 0}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(entry.value),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      Text(
        'Prochaines échéances',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if ((dashboard['upcoming'] as List? ?? []).isEmpty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune échéance à venir.'),
        ),
      ...((dashboard['upcoming'] as List? ?? []).map(taskCard)),
      const SizedBox(height: 24),
      Text('À rattraper', style: Theme.of(context).textTheme.titleLarge),
      if ((dashboard['late'] as List? ?? []).isEmpty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune tâche en retard.'),
        ),
      ...((dashboard['late'] as List? ?? []).map(taskCard)),
      const SizedBox(height: 80),
    ],
  );
  Widget tasksView() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Tous')),
                  ...statusLabels.entries.map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ),
                ],
                onChanged: (v) {
                  status = v;
                  load();
                },
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<int>(
                initialValue: subjectId,
                decoration: const InputDecoration(labelText: 'Matière'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Toutes')),
                  ...subjects.map(
                    (s) => DropdownMenuItem<int>(
                      value: s['id'] as int,
                      child: Text(
                        s['name'] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (v) {
                  subjectId = v;
                  load();
                },
              ),
            ),
            IconButton(
              tooltip: descending
                  ? 'Échéance décroissante'
                  : 'Échéance croissante',
              onPressed: () {
                descending = !descending;
                load();
              },
              icon: Icon(
                descending ? Icons.arrow_downward : Icons.arrow_upward,
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: tasks.isEmpty
            ? const Center(child: Text('Aucune tâche pour ces filtres.'))
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                children: tasks.map(taskCard).toList(),
              ),
      ),
    ],
  );
  Widget subjectsView() => subjects.isEmpty
      ? const Center(child: Text('Ajoute ta première matière.'))
      : ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          children: subjects.map((value) {
            final s = Map<String, dynamic>.from(value as Map);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(s['name'] as String),
                subtitle: Text(s['description'] as String),
                onTap: () => edit(false, s),
                trailing: IconButton(
                  tooltip: 'Supprimer la matière',
                  onPressed: () => remove(false, s),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            );
          }).toList(),
        );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(['Tableau de bord', 'Mes tâches', 'Mes matières'][tab]),
      actions: [
        IconButton(
          tooltip: 'Actualiser',
          onPressed: loading ? null : load,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          tooltip: 'Se déconnecter',
          onPressed: loggingOut ? null : logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),
    body: loading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: load, child: const Text('Réessayer')),
                ],
              ),
            ),
          )
        : [dashboardView, tasksView, subjectsView][tab](),
    floatingActionButton: loading || error != null
        ? null
        : FloatingActionButton.extended(
            onPressed: () => edit(tab != 2),
            icon: const Icon(Icons.add),
            label: Text(tab == 2 ? 'Matière' : 'Tâche'),
          ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Accueil',
        ),
        NavigationDestination(icon: Icon(Icons.checklist), label: 'Tâches'),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          label: 'Matières',
        ),
      ],
    ),
  );
}
