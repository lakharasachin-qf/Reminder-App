import 'package:demo_health/views/main_screens/reminder_screen/AddEditReminderScreen.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/provider/reminderPRO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class RemindersList extends StatefulWidget {
  final bool? isRefresh;

  const RemindersList({super.key, this.isRefresh});

  @override
  State<RemindersList> createState() => _RemindersListState();
}

class _RemindersListState extends State<RemindersList> {
  Offset? _tapPosition;

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        final reminderProvider = Provider.of<ReminderProvider>(context);
        return FutureBuilder(
          future: reminderProvider.loadReminders(),
          builder: (context, asyncSnapshot) {
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 10.h),
              itemCount: reminderProvider.reminders.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    bool currunt =
                        reminderProvider.reminders[index].isActive ?? true;
                    reminderProvider.toggleReminderActive(
                      index,
                      !currunt,
                      context,
                    );
                  },
                  onTapDown: (details) {
                    _tapPosition = details.globalPosition;
                  },
                  onLongPress: () async {
                    if (_tapPosition == null) return;
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;
                    final result = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromRect(
                        _tapPosition! & Size(10.w, 10.w),
                        Offset.zero & overlay.size,
                      ),
                      items: [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(
                            "Edit",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'cancel',
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ],
                    );
                    if (mounted && result == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditReminderScreen(
                            isEdit: true,
                            reminder: reminderProvider.reminders[index],
                          ),
                        ),
                      );
                    }
                  },
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: StretchMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) =>
                              reminderProvider.deleteReminder(index),
                          icon: Icons.delete,
                          spacing: 2.w,
                          backgroundColor: AppColors.error.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4.w),
                        ),
                      ],
                    ),
                    child: Opacity(
                      opacity:
                          reminderProvider.reminders[index].isActive ?? true
                          ? 1.0
                          : 0.6,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Container(
                                width: 1.5.w,
                                decoration: BoxDecoration(
                                  color:
                                      reminderProvider
                                              .reminders[index]
                                              .isActive ??
                                          true
                                      ? reminderProvider.reminders[index].color
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(4.w),
                                    bottomLeft: Radius.circular(4.w),
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Container(
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                  color: reminderProvider.reminders[index].color
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4.w),
                                  ),
                                ),
                                child: Icon(
                                  reminderProvider.reminders[index].icon,
                                  size: 20.sp,
                                  color:
                                      reminderProvider.reminders[index].color,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.5.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              reminderProvider
                                                  .reminders[index]
                                                  .title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.sp,
                                                  ),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddEditReminderScreen(
                                                      isEdit: true,
                                                      reminder: reminderProvider
                                                          .reminders[index],
                                                    ),
                                              ),
                                            ),
                                            icon: Icon(
                                              Icons.mode_edit_outlined,
                                              size: 20.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        '${reminderProvider.reminders[index].time?.format(context)} • ${reminderProvider.reminders[index].frequency}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                              fontSize: 16.sp,
                                            ),
                                        maxLines: null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 1.h),
                                child: Switch(
                                  value:
                                      reminderProvider
                                          .reminders[index]
                                          .isActive ??
                                      true,
                                  onChanged: (bool value) async {
                                    reminderProvider.toggleReminderActive(
                                      index,
                                      value,
                                      context,
                                    );
                                  },
                                  activeColor: AppColors.primary,
                                  inactiveTrackColor: Colors.grey.shade300,
                                ),
                              ),
                              SizedBox(width: 2.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
