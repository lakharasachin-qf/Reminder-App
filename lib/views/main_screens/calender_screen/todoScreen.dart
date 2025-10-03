// ignore_for_file: deprecated_member_use
import 'package:demo_health/Models/todoModel.dart';
import 'package:demo_health/Services/todoPrefs.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/provider/toDoPro.dart';
import 'package:demo_health/utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ToDoList extends StatefulWidget {
  DateTime selectedDate;
  ToDoList({super.key, required this.selectedDate});

  @override
  State<ToDoList> createState() => _ToDoListState();
}
//todo add the calandr View and whrn the user picks
//the day it will show that days todos and
//if the privous day's todo is not ticked then it'll show in the next day

class _ToDoListState extends State<ToDoList> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _editingController = TextEditingController();
  todoDatabase todoDB = todoDatabase();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      print("focus node changed");
    });
    shiftUnCheckedTaskToToday();
  }

  void setFocus() {
    FocusScope.of(context).requestFocus(_focusNode);
  }

  void unFocus() {
    FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);
  }

  void _addTask() {
    if (_formKey.currentState!.validate()) {
      Provider.of<todoProvider>(context, listen: false).addTask(
        TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _taskController.text,
          createdAt: DateTime.now(),
          date: widget.selectedDate,
        ),
      );
      _taskController.clear();
      FocusScope.of(context).unfocus();
      // });
    } else {
      setFocus();
    }
  }

  void _deleteTask(int index) {
    final todoTitle = todoDB.todoList[index].title;

    Provider.of<todoProvider>(context, listen: false).deleteTask(index);
    MySnackbar().showSnackBar("$todoTitle is deleted", context);
  }

  void _editTodo(int index) {
    Provider.of<todoProvider>(
      context,
      listen: false,
    ).editTodo(index, _editingController.text.toString());
    FocusScope.of(context).unfocus();
  }

  // ignore: non_constant_identifier_names
  Widget DialogBox({void Function()? onEdit}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      title: Text("Edit your Task"),

      content: TextField(
        autofocus: true,
        controller: _editingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        MaterialButton(
          onPressed: () {
            if (onEdit != null) onEdit();
            Navigator.pop(context);
            unFocus();
          },
          color: AppColors.primary,
          height: 35,
          minWidth: 85,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textColor: AppColors.background,
          child: Text("Edit"),
        ),

        MaterialButton(
          textColor: AppColors.primary,
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }

  Future<void> shiftUnCheckedTaskToToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String todayString = DateTime.now().toIso8601String().substring(
      0,
      10,
    );
    final String lastShiftedDateKEY = 'last_Shifted_Date';
    // ignore: unused_local_variable
    final String? lastShifted = prefs.getString(lastShiftedDateKEY);
    final today = DateTime.now();

    List<TodoItem> todoss = todoDB.todoList
        .where(
          (todo) =>
              (!todo.isCompleted && todo.date.year < today.year ||
              todo.date.year == today.year && todo.date.month < today.month ||
              todo.date.month == today.month && todo.date.day < today.day),
        )
        .toList();

    if (lastShifted == todayString) return;
    // ignore: unnecessary_null_comparison
    if (todoss.isEmpty) return;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            title: Text("UnChecked Tasks"),
            content: Text(
              "All of your previous unchecked tasks will be added to this day",
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              MaterialButton(
                onPressed: () async {
                  for (var todo in todoDB.todoList) {
                    if (!todo.isCompleted && todo.date.year < today.year ||
                        todo.date.year == today.year &&
                            todo.date.month < today.month ||
                        todo.date.month == today.month &&
                            todo.date.day < today.day) {
                      todo.date = DateTime(today.year, today.month, today.day);
                    }
                  }
                  todoDB.updateTodoData();
                  await prefs.setString(lastShiftedDateKEY, todayString);
                  Navigator.pop(context);
                },
                color: AppColors.primary,
                height: 35,
                minWidth: 85,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textColor: AppColors.background,
                child: Text("Add"),
              ),

              MaterialButton(
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
            ],
          );
        },
      );
    }

    // final today = DateTime.now();
    // for (var todo in todoDB.todoList) {
    //   if (!todo.isCompleted && todo.date.year < today.year ||
    //       todo.date.year == today.year && todo.date.month < today.month ||
    //       todo.date.month == today.month && todo.date.day < today.day) {
    //     todo.date = DateTime(today.year, today.month, today.day);
    //   }
    // }
    // todoDB.updateTodoData();
    // await prefs.setString(lastShiftedDateKEY, todayString);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    final TodoProvider = Provider.of<todoProvider>(context);

    final todoForSelectedDay = todoDB.todoList
        .where(
          (todo) =>
              todo.date.year == widget.selectedDate.year &&
              todo.date.month == widget.selectedDate.month &&
              todo.date.day == widget.selectedDate.day,
        )
        .toList();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => unFocus(),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: Theme.of(context).brightness == Brightness.dark
                  ? LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    )
                  : LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
            ),
          ),
          title: Text(
            "tasks for ${widget.selectedDate.toLocal().day}/${widget.selectedDate.toLocal().month}",
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    colors: [
                      AppColors.darkBackground.withOpacity(0.5),
                      AppColors.darkSurface.withOpacity(0.5),
                    ],
                  )
                : AppColors.backgroundGradient,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            focusNode: _focusNode,
                            controller: _taskController,
                            decoration: const InputDecoration(
                              hintText: 'Add a new health task...',
                            ),
                            onFieldSubmitted: (_) {
                              setFocus();
                              _addTask();
                            },
                            validator: (value) =>
                                (value == null || value.isEmpty)
                                ? 'Please enter a title'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Align(
                          alignment: Alignment.topCenter,
                          child: IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: const Icon(Icons.add),
                            onPressed: _addTask,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: FutureBuilder(
                  future: TodoProvider.getToDoDATA(),
                  builder: (context, asyncSnapshot) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: todoForSelectedDay.length,
                      itemBuilder: (context, index) {
                        // final task = todoForSelectedDay[index];
                        return GestureDetector(
                          onTap: () {
                            final todo = todoForSelectedDay[index];
                            final mainIndex = todoDB.todoList.indexWhere(
                              (t) => t.id == todo.id,
                            );
                            if (mainIndex != -1) {
                              TodoProvider.toggleTodo(mainIndex);
                            }
                          },
                          child: Slidable(
                            key: Key(todoForSelectedDay[index].id),
                            endActionPane: ActionPane(
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    final todo = todoForSelectedDay[index];
                                    final mainIndex = todoDB.todoList
                                        .indexWhere((t) => t.id == todo.id);
                                    if (mainIndex != -1) {
                                      _deleteTask(mainIndex);
                                    }
                                  },
                                  icon: Icons.delete,
                                  spacing: 10,
                                  backgroundColor: AppColors.error.withOpacity(
                                    0.9,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ],
                            ),
                            child: Card(
                              // color: Theme.of(context).canvasColor,
                              elevation: 2,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                leading: Checkbox(
                                  value: todoForSelectedDay[index].isCompleted,
                                  onChanged: (bool? value) {
                                    final todo = todoForSelectedDay[index];
                                    final mainIndex = todoDB.todoList
                                        .indexWhere((t) => t.id == todo.id);
                                    if (mainIndex != -1) {
                                      // setState(() {
                                      //   todoDB.todoList[mainIndex].isCompleted =
                                      //       value ?? false;
                                      // });
                                      // todoDB.updateTodoData();
                                      TodoProvider.toggleTodo(mainIndex);
                                    }
                                  },
                                  activeColor: AppColors.success,
                                  shape: const CircleBorder(),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    _editingController.text =
                                        todoForSelectedDay[index].title;
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DialogBox(
                                          onEdit: () {
                                            final todo =
                                                todoForSelectedDay[index];
                                            final mainIndex = todoDB.todoList
                                                .indexWhere(
                                                  (t) => t.id == todo.id,
                                                );
                                            if (mainIndex != -1) {
                                              _editTodo(mainIndex);
                                            }
                                            // Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.mode_edit_outlined,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                title: Text(
                                  todoForSelectedDay[index].title,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        decoration:
                                            todoForSelectedDay[index]
                                                .isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color:
                                            todoForSelectedDay[index]
                                                .isCompleted
                                            ? Colors.grey
                                            : Theme.of(context).brightness ==
                                                  Brightness.dark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
