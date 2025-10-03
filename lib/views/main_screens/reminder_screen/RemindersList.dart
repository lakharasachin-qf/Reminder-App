// import 'package:demo_health/Services/SharedPrefServices.dart';
import 'package:demo_health/views/main_screens/reminder_screen/AddEditReminderScreen.dart';
import 'package:demo_health/Theme/AppTheme.dart';
import 'package:demo_health/provider/reminderPRO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class RemindersList extends StatefulWidget {
  final bool? isRefresh;

  const RemindersList({super.key, this.isRefresh});

  @override
  State<RemindersList> createState() => _RemindersListState();
}

class _RemindersListState extends State<RemindersList> {
  // final Sharedprefservices _sharedprefservices = Sharedprefservices();

  // @override
  // void initState() {
  //   super.initState();
  //   _loadReminders();
  // }

  // Future<void> _loadReminders() async {
  //   await _sharedprefservices.getReminder();
  //   setState(() {});
  // }

  // void _deleteReminder(int index) {
  //   final reminderId = _sharedprefservices.reminderList[index].id;
  //   _sharedprefservices.reminderList.removeAt(index);
  //   setState(() {
  //     _sharedprefservices.saveReminder();
  //   });
  //   try {
  //     print("Snoti is deleting");
  //     NotiServices().notificationPlugin.cancel(reminderId);
  //     print("Snoti deleted");
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  Offset? _tapPosition;
  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    return FutureBuilder(
      future: reminderProvider.loadReminders(),
      builder: (context, asyncSnapshot) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 80), // Padding for FAB
          itemCount: reminderProvider.reminders.length,
          itemBuilder: (context, index) {
            // final reminder = _sharedprefservices.reminderList[index];
            return GestureDetector(
              onTap: () {
                bool currunt =
                    reminderProvider.reminders[index].isActive ?? true;
                reminderProvider.toggleReminderActive(index, !currunt, context);
              },
              onTapDown: (details) {
                _tapPosition = details.globalPosition;
              },
              onLongPress: () async {
                if (_tapPosition == null) return;
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final result = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromRect(
                    _tapPosition! & const Size(40, 40),
                    Offset.zero & overlay.size,
                  ),
                  items: [
                    PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(value: 'cancel', child: Text("Cancel")),
                  ],
                );
                if (mounted) {
                  if (result == 'edit') {
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
                }
              },
              child: Slidable(
                endActionPane: ActionPane(
                  motion: StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => reminderProvider.deleteReminder(index),
                      icon: Icons.delete,
                      spacing: 10,
                      backgroundColor: AppColors.error.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ],
                ),
                child: Opacity(
                  opacity: reminderProvider.reminders[index].isActive ?? true
                      ? 1.0
                      : 0.6,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color:
                                  reminderProvider.reminders[index].isActive ??
                                      true
                                  ? reminderProvider.reminders[index].color
                                  : Colors.grey.shade400,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: reminderProvider.reminders[index].color
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                            child: Icon(
                              reminderProvider.reminders[index].icon,
                              size: 32,
                              color: reminderProvider.reminders[index].color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          size: 19,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '${reminderProvider.reminders[index].time?.format(context)} • ${reminderProvider.reminders[index].frequency}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey.shade600),
                                    maxLines: null,
                                    // overflow: TextOverflow.visible,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ), // Add padding to switch
                            child: Switch(
                              value:
                                  reminderProvider.reminders[index].isActive ??
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
                          const SizedBox(width: 8),
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
  }
}
