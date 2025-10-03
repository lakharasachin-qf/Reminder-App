import 'package:demo_health/Services/todoPrefs.dart';
import 'package:flutter/material.dart';
import '../Models/todoModel.dart';

// ignore: camel_case_types
class todoProvider extends ChangeNotifier {
  final todoDatabase _todoDB = todoDatabase();
  List<TodoItem> get todoList => _todoDB.todoList;

  void deleteTask(int index) {
    // final todoTitle = todoDB.todoList[index].title;
    _todoDB.todoList.removeAt(index);
    _todoDB.updateTodoData();
    notifyListeners();
    // MySnackbar().showSnackBar("$todoTitle is deleted", context);
  }

  void editTodo(int index, String editingController) {
    _todoDB.todoList[index].title = editingController.toString();
    _todoDB.updateTodoData();
    // FocusScope.of(context).unfocus();
    notifyListeners();
  }

  void addTask(TodoItem todoDB) {
    _todoDB.todoList.insert(0, todoDB);
    _todoDB.updateTodoData();
    notifyListeners();
  }

  Future<void> getToDoDATA() async {
    await _todoDB.getTodo();
    _todoDB.updateTodoData();
    notifyListeners();
  }

  void toggleTodo(int mainIndex) {
    _todoDB.todoList[mainIndex].isCompleted =
        !_todoDB.todoList[mainIndex].isCompleted;
    _todoDB.updateTodoData();
    notifyListeners();
  }

  List<TodoItem> markers(day) {
    final todoMarkers = _todoDB.todoList
        .where(
          (todo) =>
              todo.date.year == day.year &&
              todo.date.month == day.month &&
              todo.date.day == day.day,
        )
        .toList();
    notifyListeners();
    return todoMarkers;
  }
}
