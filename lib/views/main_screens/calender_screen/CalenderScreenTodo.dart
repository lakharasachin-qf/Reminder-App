import 'package:smart_reminder/views/main_screens/calender_screen/todoScreen.dart';
import 'package:smart_reminder/Theme/AppTheme.dart';
import 'package:smart_reminder/provider/toDoPro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
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
    return Sizer(
      builder: (context, orientation, deviceType) {
        final TodoProvider = Provider.of<todoProvider>(context);
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
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
                              borderRadius: BorderRadius.circular(3.w),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 1.5,
                                  offset: Offset(0, 0.5.h),
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
                                    padding: EdgeInsets.only(
                                      top: 2.h,
                                      left: 4.w,
                                    ),
                                    child: Text(
                                      "Task Calender",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
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
                                          builder: (context) => ToDoList(
                                            selectedDate: selectedDay,
                                          ),
                                        ),
                                      );
                                      setState(() {});
                                    },
                                    headerStyle: HeaderStyle(
                                      titleTextStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      leftChevronIcon: Icon(
                                        Icons.arrow_left,
                                        color: AppColors.primary,
                                        size: 20.sp,
                                      ),
                                      rightChevronIcon: Icon(
                                        Icons.arrow_right,
                                        color: AppColors.primary,
                                        size: 20.sp,
                                      ),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      todayDecoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      selectedDecoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(
                                          3.w,
                                        ),
                                      ),
                                      weekendTextStyle: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15.sp,
                                      ),
                                      selectedTextStyle: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.white,
                                      ),
                                      todayTextStyle: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      defaultTextStyle: TextStyle(
                                        fontSize: 15.sp,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    calendarBuilders: CalendarBuilders(
                                      dowBuilder: (context, day) {
                                        if (day.weekday == DateTime.sunday) {
                                          final text = DateFormat.E().format(
                                            day,
                                          );
                                          return Center(
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          );
                                        }
                                        return null;
                                      },
                                      markerBuilder: (context, day, events) {
                                        final tasksForDay = TodoProvider
                                            .todoList
                                            .where(
                                              (todo) =>
                                                  todo.date.year == day.year &&
                                                  todo.date.month ==
                                                      day.month &&
                                                  todo.date.day == day.day,
                                            )
                                            .toList();
                                        if (tasksForDay.isNotEmpty) {
                                          return Positioned(
                                            right: 1.w,
                                            bottom: 1.w,
                                            child: Container(
                                              padding: EdgeInsets.all(2.w),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryDark,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${tasksForDay.length}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15.sp,
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
      },
    );
  }
}
