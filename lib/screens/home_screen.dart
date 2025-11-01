import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _apiMessage = "Učitavam podatke...";

  @override
  void initState() {
    super.initState();
    _loadApiData();
  }

  Future<void> _loadApiData() async {
    final result = await ApiService.fetchTodoTitle();
    setState(() {
      _apiMessage = result ?? "Došlo je do greške prilikom učitavanja API podataka.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    List<Widget> pages = [
      TodoPage(isDarkMode: Theme.of(context).brightness == Brightness.dark),
      NotesPage(isDarkMode: Theme.of(context).brightness == Brightness.dark),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Note & Do'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Odjavi se",
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              "API poruka: $_apiMessage",
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          Expanded(child: pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
        ],
      ),
    );
  }
}

// ================== TO-DO PAGE ==================
class TodoPage extends StatefulWidget {
  final bool isDarkMode;
  const TodoPage({super.key, required this.isDarkMode});

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _currentTime = _getCurrentTime());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentTime() => DateFormat('HH:mm:ss').format(DateTime.now());

  void _addTask(String task) {
    if (task.isEmpty) return;
    setState(() {
      _tasks.add(task);
      _controller.clear();
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      _completedTasks.contains(index)
          ? _completedTasks.remove(index)
          : _completedTasks.add(index);
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _completedTasks.remove(index);
      _completedTasks
          .toList()
          .asMap()
          .forEach((i, v) => _completedTasks.remove(i > index ? i - 1 : i));
    });
  }

  @override
  Widget build(BuildContext context) {
    final textFieldBg = widget.isDarkMode ? Colors.grey[800] : Colors.white;
    final listBg = widget.isDarkMode ? Colors.grey[900] : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Trenutno vreme: $_currentTime',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: textFieldBg,
              hintText: 'Dodaj novi zadatak',
              hintStyle: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addTask(_controller.text),
              ),
            ),
            onSubmitted: _addTask,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final isCompleted = _completedTasks.contains(index);
                return Card(
                  color: listBg,
                  shadowColor: Colors.black26,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                        color: widget.isDarkMode
                            ? (isCompleted ? Colors.white54 : Colors.white)
                            : (isCompleted ? Colors.black54 : Colors.black),
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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
  final bool isDarkMode;
  const NotesPage({super.key, required this.isDarkMode});

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _currentTime = _getCurrentTime());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentTime() => DateFormat('HH:mm:ss').format(DateTime.now());

  void _addNote(String note) {
    if (note.isEmpty) return;
    setState(() {
      _notes.add(note);
      _noteController.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() => _notes.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final textFieldBg = widget.isDarkMode ? Colors.grey[800] : Colors.white;
    final listBg = widget.isDarkMode ? Colors.grey[900] : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Trenutno vreme: $_currentTime',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              filled: true,
              fillColor: textFieldBg,
              hintText: 'Napiši belešku',
              hintStyle: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addNote(_noteController.text),
              ),
            ),
            onSubmitted: _addNote,
            style: TextStyle(
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  color: listBg,
                  shadowColor: Colors.black26,
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      note,
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
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