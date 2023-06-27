import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'todo.dart';


void main() {
  runApp(TodoApp());
}


class TodoModel extends ChangeNotifier {
  late Database _database;
  List<Todo> todos = [];

  Future<void> initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'todo.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY,
            title TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );

    todos = await _fetchTodos();
    notifyListeners();
  }

  Future<List<Todo>> _fetchTodos() async {
    final List<Map<String, dynamic>> maps = await _database.query('todos');

    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<void> addTodo(String title) async {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
    );

    await _database.insert(
      'todos',
      newTodo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    todos = await _fetchTodos();
    notifyListeners();
  }

  Future<void> deleteTodo(int id) async {
    await _database.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );

    todos = await _fetchTodos();
    notifyListeners();
  }

  Future<void> toggleCompletion(int id, bool isCompleted) async {
    await _database.update(
      'todos',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );

    todos = await _fetchTodos();
    notifyListeners();
  }

  // todo await todoModel.editTodoTitle(todo.id, newTodoTitle);
  Future<void> editTodoTitle(int id, String newTitle) async {
    await _database.update(
      'todos',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [id],
    );

    todos = await _fetchTodos();
    notifyListeners();
  }


}


class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TodoModel(),
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodoListScreen(),
      ),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoModel = Provider.of<TodoModel>(context);
    todoModel.initializeDatabase();
    final todos = todoModel.todos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            title: Text(todo.title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: todo.isCompleted,
                  onChanged: (value) {
                    // todoModel.toggleCompletion(index);
                    todoModel.toggleCompletion(todo.id, value ?? false);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    todoModel.deleteTodo(todo.id);
                  },
                ),
              ],
            ),
            onTap: () {
              _editTodoTitle(context, todoModel, todo);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addTodoDialog(context, todoModel);
        },
      ),
    );
  }

  void _addTodoDialog(BuildContext context, TodoModel todoModel) {
    String newTodoTitle = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Todo'),
          content: TextField(
            onChanged: (value) {
              newTodoTitle = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                todoModel.addTodo(newTodoTitle);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _editTodoTitle(BuildContext context, TodoModel todoModel, Todo todo) {
    // String newTodoTitle = todoModel.todos[index].title;
    String newTodoTitle = todo.title;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            controller: TextEditingController(text: newTodoTitle),
            onChanged: (value) {
              newTodoTitle = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed:  () async {
                // todoModel.editTodoTitle(todo.id, newTodoTitle);
                await todoModel.editTodoTitle(todo.id, newTodoTitle);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
