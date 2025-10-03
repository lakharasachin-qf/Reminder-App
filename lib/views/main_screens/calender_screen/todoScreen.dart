import 'package:demo_health/Models/todoModel.dart';
import 'package:demo_health/Services/todoPrefs.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/provider/toDoPro.dart';
import 'package:demo_health/utils/snackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class ToDoList extends StatefulWidget {
  DateTime selectedDate;
  ToDoList({super.key, required this.selectedDate});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

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

  Widget DialogBox({void Function()? onEdit}) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      titleTextStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      ),
      title: Text("Edit your Task"),
      content: TextField(
        autofocus: true,
        controller: _editingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.w)),
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
          height: 4.h,
          minWidth: 20.w,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          textColor: AppColors.background,
          child: Text("Edit", style: TextStyle(fontSize: 15.sp)),
        ),
        MaterialButton(
          textColor: AppColors.primary,
          onPressed: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
          },
          child: Text("Cancel", style: TextStyle(fontSize: 15.sp)),
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
    final String? lastShifted = prefs.getString(lastShiftedDateKEY);
    final today = DateTime.now();

    List<TodoItem> todoss = todoDB.todoList
        .where(
          (todo) =>
              (!todo.isCompleted &&
              (todo.date.year < today.year ||
                  (todo.date.year == today.year &&
                      todo.date.month < today.month) ||
                  (todo.date.month == today.month &&
                      todo.date.day < today.day))),
        )
        .toList();

    if (lastShifted == todayString || todoss.isEmpty) return;

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.w),
            ),
            title: Text("UnChecked Tasks", style: TextStyle(fontSize: 16.sp)),
            content: Text(
              "All of your previous unchecked tasks will be added to this day",
              style: TextStyle(fontSize: 15.sp),
            ),
            actions: [
              MaterialButton(
                onPressed: () async {
                  for (var todo in todoDB.todoList) {
                    if (!todo.isCompleted &&
                        (todo.date.year < today.year ||
                            (todo.date.year == today.year &&
                                todo.date.month < today.month) ||
                            (todo.date.month == today.month &&
                                todo.date.day < today.day))) {
                      todo.date = DateTime(today.year, today.month, today.day);
                    }
                  }
                  todoDB.updateTodoData();
                  await prefs.setString(lastShiftedDateKEY, todayString);
                  Navigator.pop(context);
                },
                color: AppColors.primary,
                height: 4.h,
                minWidth: 20.w,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                textColor: AppColors.background,
                child: Text("Add", style: TextStyle(fontSize: 15.sp)),
              ),
              MaterialButton(
                textColor: AppColors.primary,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: TextStyle(fontSize: 15.sp)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
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
                style: TextStyle(fontSize: 16.sp),
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
                    padding: EdgeInsets.all(4.w),
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
                                decoration: InputDecoration(
                                  hintText: 'Add a new health task...',
                                  hintStyle: TextStyle(fontSize: 15.sp),
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
                            SizedBox(width: 2.w),
                            Align(
                              alignment: Alignment.topCenter,
                              child: IconButton.filled(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                icon: Icon(Icons.add, size: 18.sp),
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
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          itemCount: todoForSelectedDay.length,
                          itemBuilder: (context, index) {
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
                                      spacing: 2.w,
                                      backgroundColor: AppColors.error
                                          .withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(4.w),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 1.h,
                                      horizontal: 2.w,
                                    ),
                                    leading: Checkbox(
                                      value:
                                          todoForSelectedDay[index].isCompleted,
                                      onChanged: (bool? value) {
                                        final todo = todoForSelectedDay[index];
                                        final mainIndex = todoDB.todoList
                                            .indexWhere((t) => t.id == todo.id);
                                        if (mainIndex != -1) {
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
                                                final mainIndex = todoDB
                                                    .todoList
                                                    .indexWhere(
                                                      (t) => t.id == todo.id,
                                                    );
                                                if (mainIndex != -1) {
                                                  _editTodo(mainIndex);
                                                }
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
                                        size: 18.sp,
                                      ),
                                    ),
                                    title: Text(
                                      todoForSelectedDay[index].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
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
                                                : Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 15.sp,
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
      },
    );
  }
}
