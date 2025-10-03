import 'dart:convert';
import 'package:smart_reminder/Models/todoModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class todoDatabase {
  static final todoDatabase _instance = todoDatabase._internal();
  factory todoDatabase() => _instance;
  todoDatabase._internal();

  List<TodoItem> todoList = [];

  Future<void> updateTodoData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoString = todoList
        .map((x) => jsonEncode(x.toJson()))
        .toList();
    await prefs.setStringList("toDoList", todoString);
  }

  Future<void> getTodo() async {
    // call setState
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoString = prefs.getStringList('toDoList');
    if (todoString != null) {
      todoList = todoString
          .map((x) => TodoItem.fromJson(jsonDecode(x)))
          .toList();
    }
  }
}
