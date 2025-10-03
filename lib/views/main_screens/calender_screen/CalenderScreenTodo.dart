import 'package:demo_health/views/main_screens/calender_screen/todoScreen.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/provider/toDoPro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// import '../Services/todoPrefs.dart';

class CalenderScreen extends StatefulWidget {
  // final DateTime _selectedDate = DateTime.now();

  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  // todoDatabase todoDB = todoDatabase();
  final DateTime _selectedDate = DateTime.now();
  late Future<void> _loadTodosF;

  @override
  void initState() {
    _loadTodosF = Provider.of<todoProvider>(
      context,
      listen: false,
    ).getToDoDATA();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    final TodoProvider = Provider.of<todoProvider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          verticalDirection: VerticalDirection.down,
          children: [
            Flexible(
              child: FutureBuilder(
                future: _loadTodosF,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Colors.transparent,
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 1.5,
                              offset: Offset(0, 2),
                              blurStyle: BlurStyle.outer,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  left: 20,
                                ),
                                child: Text(
                                  "Health Task Calender",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                              TableCalendar(
                                focusedDay: _selectedDate,
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime(2100, 1, 1),
                                calendarFormat: _calendarFormat,
                                onFormatChanged: (format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                },
                                selectedDayPredicate: (day) =>
                                    isSameDay(_selectedDate, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ToDoList(selectedDate: selectedDay),
                                    ),
                                  );
                                  setState(() {});
                                },
                                headerStyle: HeaderStyle(
                                  titleTextStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  leftChevronIcon: Icon(
                                    Icons.arrow_left,
                                    color: AppColors.primary,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.arrow_right,
                                    color: AppColors.primary,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: AppColors.primary.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  weekendTextStyle: TextStyle(
                                    color: Colors.red,
                                  ),
                                  selectedTextStyle: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                  todayTextStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  defaultTextStyle: TextStyle(
                                    fontSize: 15,
                                    color: AppColors.primary,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  dowBuilder: (context, day) {
                                    if (day.weekday == DateTime.sunday) {
                                      final text = DateFormat.E().format(day);
                                      return Center(
                                        child: Text(
                                          text,
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                  markerBuilder: (context, day, events) {
                                    // Build a map of tasks per day
                                    final tasksForDay = TodoProvider.todoList
                                        .where(
                                          (todo) =>
                                              todo.date.year == day.year &&
                                              todo.date.month == day.month &&
                                              todo.date.day == day.day,
                                        )
                                        .toList();
                                    // final tasksForDay = TodoProvider.markers(day);
                                    if (tasksForDay.isNotEmpty) {
                                      return Positioned(
                                        right: 4,
                                        bottom: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryDark,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${tasksForDay.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                rowHeight: constraints.maxHeight / 8,
                              ),
                            ],
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
    );
  }
}
