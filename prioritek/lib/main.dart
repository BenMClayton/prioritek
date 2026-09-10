import 'package:flutter/material.dart';

void main() => runApp(const PrioritekApp());

class PrioritekApp extends StatelessWidget {
  const PrioritekApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C9BFF),
      brightness: Brightness.dark,
      surface: const Color(0xFF111722),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prioritek',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF090D14),
        cardTheme: const CardTheme(
          color: Color(0xFF111722),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: const PriorityBoard(),
    );
  }
}

class PriorityTask {
  PriorityTask({
    required this.title,
    required this.impact,
    required this.urgency,
    this.completed = false,
  });

  final String title;
  final int impact;
  final int urgency;
  bool completed;

  int get score => impact * 2 + urgency;

  String get priority {
    if (score >= 13) return 'Critical';
    if (score >= 10) return 'High';
    if (score >= 7) return 'Medium';
    return 'Low';
  }
}

class PriorityBoard extends StatefulWidget {
  const PriorityBoard({super.key});

  @override
  State<PriorityBoard> createState() => _PriorityBoardState();
}

class _PriorityBoardState extends State<PriorityBoard> {
  final List<PriorityTask> _tasks = [
    PriorityTask(title: 'Resolve checkout error', impact: 5, urgency: 5),
    PriorityTask(title: 'Prepare release notes', impact: 3, urgency: 4),
    PriorityTask(
        title: 'Review dashboard accessibility', impact: 4, urgency: 2),
  ];

  List<PriorityTask> get _orderedTasks => [..._tasks]..sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      return b.score.compareTo(a.score);
    });

  Future<void> _showAddTaskDialog() async {
    final titleController = TextEditingController();
    double impact = 3;
    double urgency = 3;

    final task = await showDialog<PriorityTask>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add a task'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  maxLength: 80,
                  decoration: const InputDecoration(
                    labelText: 'Task',
                    hintText: 'What needs attention?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Impact · ${impact.round()}'),
                Slider(
                  value: impact,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: impact.round().toString(),
                  onChanged: (value) => setDialogState(() => impact = value),
                ),
                Text('Urgency · ${urgency.round()}'),
                Slider(
                  value: urgency,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: urgency.round().toString(),
                  onChanged: (value) => setDialogState(() => urgency = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(
                  context,
                  PriorityTask(
                    title: title,
                    impact: impact.round(),
                    urgency: urgency.round(),
                  ),
                );
              },
              child: const Text('Add task'),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    if (task != null) setState(() => _tasks.add(task));
  }

  @override
  Widget build(BuildContext context) {
    final active = _tasks.where((task) => !task.completed).length;
    final completed = _tasks.length - active;
    final highPriority =
        _tasks.where((task) => !task.completed && task.score >= 10).length;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Header(onAdd: _showAddTaskDialog)),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  SliverToBoxAdapter(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _Metric(
                            label: 'Active',
                            value: active,
                            colour: const Color(0xFF7C9BFF)),
                        _Metric(
                            label: 'High priority',
                            value: highPriority,
                            colour: const Color(0xFFFFB86B)),
                        _Metric(
                            label: 'Completed',
                            value: completed,
                            colour: const Color(0xFF72D5A5)),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text('Priority queue',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        const Text('Impact × 2 + urgency',
                            style: TextStyle(color: Color(0xFF8B98AA))),
                      ],
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (_tasks.isEmpty)
                    SliverToBoxAdapter(
                        child: _EmptyState(onAdd: _showAddTaskDialog))
                  else
                    SliverList.separated(
                      itemCount: _orderedTasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = _orderedTasks[index];
                        return _TaskCard(
                          task: task,
                          onChanged: (value) =>
                              setState(() => task.completed = value),
                          onDelete: () => setState(() => _tasks.remove(task)),
                        );
                      },
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  const SliverToBoxAdapter(
                    child: Text(
                      'Prototype data stays in memory and resets when the app closes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF718096)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddTaskDialog,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PRIORITEK',
                    style: TextStyle(
                        color: Color(0xFF7C9BFF),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2)),
                SizedBox(height: 8),
                Text('Make the next decision obvious.',
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add task')),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.label, required this.value, required this.colour});

  final String label;
  final int value;
  final Color colour;

  @override
  Widget build(BuildContext context) => Container(
        width: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111722),
          border: Border.all(color: const Color(0xFF263247)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w700, color: colour)),
            Text(label, style: const TextStyle(color: Color(0xFFA5B0C0))),
          ],
        ),
      );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard(
      {required this.task, required this.onChanged, required this.onDelete});

  final PriorityTask task;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDelete;

  Color get priorityColour => switch (task.priority) {
        'Critical' => const Color(0xFFFF7E8A),
        'High' => const Color(0xFFFFB86B),
        'Medium' => const Color(0xFF7C9BFF),
        _ => const Color(0xFF72D5A5),
      };

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Checkbox(
                  value: task.completed,
                  onChanged: (value) => onChanged(value ?? false)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration:
                            task.completed ? TextDecoration.lineThrough : null,
                        color: task.completed ? const Color(0xFF718096) : null,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                        'Impact ${task.impact} · Urgency ${task.urgency} · Score ${task.score}',
                        style: const TextStyle(color: Color(0xFF8B98AA))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: priorityColour.withAlpha(24),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(task.priority,
                    style: TextStyle(
                        color: priorityColour, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete task',
                  icon: const Icon(Icons.close, size: 19)),
            ],
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline, size: 38),
              const SizedBox(height: 12),
              const Text('Nothing is competing for attention.'),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: onAdd, child: const Text('Add the first task')),
            ],
          ),
        ),
      );
}
