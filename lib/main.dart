import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(TodoApp());
}

class Todo {
  String title;
  bool isCompleted;

  Todo({
    required this.title,
    this.isCompleted = false,
  });
}

class TodoModel extends ChangeNotifier {
  List<Todo> todos = [];

  void addTodo(String title) {
    todos.add(Todo(title: title));
    notifyListeners();
  }

  void deleteTodo(int index) {
    todos.removeAt(index);
    notifyListeners();
  }

  void toggleCompletion(int index) {
    todos[index].isCompleted = !todos[index].isCompleted;
    notifyListeners();
  }

  void editTodoTitle(int index, String newTitle) {
    todos[index].title = newTitle;
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
                  onChanged: (_) {
                    todoModel.toggleCompletion(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    todoModel.deleteTodo(index);
                  },
                ),
              ],
            ),
            onTap: () {
              _editTodoTitle(context, todoModel, index);
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

  void _editTodoTitle(BuildContext context, TodoModel todoModel, int index) {
    String newTodoTitle = todoModel.todos[index].title;

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
              onPressed: () {
                todoModel.editTodoTitle(index, newTodoTitle);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
