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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        title: Text(
          t['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
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

  Widget emptyState(
    IconData icon,
    String title,
    String message,
    String action,
    VoidCallback onPressed,
  ) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xffd9f1eb),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: const Color(0xff087f72)),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xff61757d), height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: Text(action),
          ),
        ],
      ),
    ),
  );

  Widget dashboardView() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff075e57), Color(0xff087f72)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.school_outlined, color: Color(0xffaee7d7), size: 32),
            SizedBox(height: 16),
            Text(
              'Une semaine bien organisée.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tes cours et tes échéances, au même endroit.',
              style: TextStyle(color: Color(0xffd1eee7), height: 1.5),
            ),
          ],
        ),
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
              width: (MediaQuery.sizeOf(context).width - 40) / 2,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dashboard[entry.key] ?? 0}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: entry.key == 'overdue'
                                  ? const Color(0xffb54b3a)
                                  : const Color(0xff087f72),
                            ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: status,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tous')),
                      ...statusLabels.entries.map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      status = v;
                      load();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: subjectId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Matière'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Toutes'),
                      ),
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
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${tasks.length} tâche${tasks.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: Color(0xff61757d),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    descending = !descending;
                    load();
                  },
                  icon: Icon(
                    descending ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 18,
                  ),
                  label: Text(descending ? 'Plus lointaines' : 'Plus proches'),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: tasks.isEmpty
            ? emptyState(
                Icons.checklist_rounded,
                status != null || subjectId != null
                    ? 'Aucun résultat'
                    : 'Tout commence par une tâche',
                status != null || subjectId != null
                    ? 'Essaie un autre statut ou une autre matière.'
                    : 'Prépare ton prochain devoir et garde tes échéances en vue.',
                subjects.isEmpty ? 'Ajouter une matière' : 'Créer une tâche',
                () => edit(subjects.isNotEmpty),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                children: tasks.map(taskCard).toList(),
              ),
      ),
    ],
  );
  Widget subjectsView() => subjects.isEmpty
      ? emptyState(
          Icons.auto_stories_outlined,
          'Tes cours, bien rangés',
          'Ajoute une matière pour y associer tes devoirs et projets.',
          'Ajouter une matière',
          () => edit(false),
        )
      : ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          children: subjects.map((value) {
            final s = Map<String, dynamic>.from(value as Map);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                title: Text(
                  s['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
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
