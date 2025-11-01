import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    List<Widget> pages = [
      TodoPage(isDark: isDark),
      NotesPage(isDark: isDark),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        title: const Text('Note & Do'),
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Odjavi se",
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Odjava"),
                  content: const Text("Da li ste sigurni da želite da se odjavite?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Otkaži"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Odjavi se"),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true && context.mounted) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_rounded),
            label: 'Notes',
          ),
        ],
      ),
    );
  }
}

// ================== TO-DO PAGE ==================
class TodoPage extends StatefulWidget {
  final bool isDark;
  const TodoPage({super.key, required this.isDark});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tasks = [];
  final Set<int> _completedTasks = {};
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  void _addTask(String task) {
    if (task.isEmpty) return;
    setState(() {
      _tasks.add(task);
      _controller.clear();
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      if (_completedTasks.contains(index)) {
        _completedTasks.remove(index);
      } else {
        _completedTasks.add(index);
      }
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _completedTasks.remove(index);
      final newSet = <int>{};
      for (var i in _completedTasks) {
        newSet.add(i > index ? i - 1 : i);
      }
      _completedTasks
        ..clear()
        ..addAll(newSet);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final fieldColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      color: isDark ? Colors.black : Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Trenutno vreme: $_currentTime',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: fieldColor,
              hintText: 'Dodaj novi zadatak...',
              hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_rounded, color: Colors.deepPurple),
                onPressed: () => _addTask(_controller.text),
              ),
            ),
            style: TextStyle(color: textColor),
            onSubmitted: _addTask,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCompleted = _completedTasks.contains(index);
                return Card(
                  color: bgColor,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _toggleComplete(index),
                      activeColor: Colors.deepPurple,
                    ),
                    title: Text(
                      task,
                      style: TextStyle(
                        color: textColor,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================== NOTES PAGE ==================
class NotesPage extends StatefulWidget {
  final bool isDark;
  const NotesPage({super.key, required this.isDark});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _notes = [];
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  void _addNote(String note) {
    if (note.isEmpty) return;
    setState(() {
      _notes.add(note);
      _noteController.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final fieldColor = isDark ? Colors.grey[800] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      color: isDark ? Colors.black : Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Trenutno vreme: $_currentTime',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              filled: true,
              fillColor: fieldColor,
              hintText: 'Napiši belešku...',
              hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_rounded, color: Colors.deepPurple),
                onPressed: () => _addNote(_noteController.text),
              ),
            ),
            style: TextStyle(color: textColor),
            onSubmitted: _addNote,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  color: bgColor,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    title: Text(
                      note,
                      style: TextStyle(color: textColor),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                      onPressed: () => _deleteNote(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}