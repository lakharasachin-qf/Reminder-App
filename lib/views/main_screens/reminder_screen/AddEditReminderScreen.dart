import 'dart:math';
import 'package:smart_reminder/Models/reminders.dart';
import 'package:smart_reminder/Services/SharedPrefServices.dart';
import 'package:smart_reminder/Theme/AppTheme.dart';
import 'package:smart_reminder/notiServices/noti_Services.dart';
import 'package:smart_reminder/provider/reminderPRO.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddEditReminderScreen extends StatefulWidget {
  final HealthReminder? reminder;
  final bool isEdit;

  const AddEditReminderScreen({super.key, this.reminder, required this.isEdit});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final Sharedprefservices _sharedprefservices = Sharedprefservices();
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedFrequency = 'Daily';
  IconData _selectedIcon = Icons.medication;
  Color _selectedColor = AppColors.primary;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'Once'];
  final List<IconData> _icons = [
    Icons.medication,
    Icons.fitness_center,
    Icons.water_drop,
    Icons.wb_sunny,
    Icons.restaurant,
    Icons.bed,
    Icons.favorite,
    Icons.local_hospital,
  ];
  final List<Color> _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.warning,
    AppColors.error,
    AppColors.success,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _selectedFrequency = widget.reminder!.frequency;
      _selectedTime = widget.reminder!.time ?? TimeOfDay.now();
      _selectedColor = widget.reminder!.color;
      _selectedIcon = widget.reminder!.icon; // from model getter
    }
    _sharedprefservices.getReminder();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void unFocus() {
    FocusScope.of(context).unfocus(disposition: UnfocusDisposition.scope);
  }

  // 🔑 Convert IconData -> String name for saving
  String iconToName(IconData icon) {
    if (icon == Icons.medication) return 'medication';
    if (icon == Icons.fitness_center) return 'fitness_center';
    if (icon == Icons.water_drop) return 'water_drop';
    if (icon == Icons.wb_sunny) return 'wb_sunny';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.bed) return 'bed';
    if (icon == Icons.favorite) return 'favorite';
    if (icon == Icons.local_hospital) return 'local_hospital';
    return 'notifications';
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => unFocus(),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.isEdit ? "Edit Reminder" : "New Reminder",
                style: TextStyle(fontSize: 16.sp),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: Theme.of(context).brightness == Brightness.dark
                      ? LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                        )
                      : AppColors.primaryGradient,
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context).brightness == Brightness.dark
                    ? LinearGradient(
                        colors: [
                          AppColors.darkBackground,
                          AppColors.darkBackground.withOpacity(0.2),
                        ],
                      )
                    : AppColors.backgroundGradient,
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 2.h),
                  children: [
                    _buildCard('Details', [
                      TextFormField(
                        controller: _titleController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          labelText: 'Reminder Title',
                          prefixIcon: Icon(Icons.title, size: 18.sp),
                          labelStyle: TextStyle(fontSize: 15.sp),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Please enter a title'
                            : null,
                      ),
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          prefixIcon: Icon(Icons.repeat, size: 18.sp),
                          labelStyle: TextStyle(fontSize: 15.sp),
                        ),
                        items: _frequencies
                            .map(
                              (f) => DropdownMenuItem(
                                value: f,
                                child: Text(
                                  f,
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedFrequency = value!),
                      ),
                      SizedBox(height: 2.h),
                      ListTile(
                        leading: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                        title: Text(
                          'Select Time',
                          style: TextStyle(fontSize: 15.sp),
                        ),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(fontSize: 15.sp),
                        ),
                        onTap: _selectTime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ]),
                    SizedBox(height: 2.h),
                    _buildCard('Icon & Color', [
                      _buildChoicePicker<IconData>(
                        title: 'Choose Icon',
                        choices: _icons,
                        selectedValue: _selectedIcon,
                        onSelected: (icon) =>
                            setState(() => _selectedIcon = icon),
                        builder: (icon, isSelected) => Icon(
                          icon,
                          color: isSelected ? AppColors.primary : Colors.grey,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildChoicePicker<Color>(
                        title: 'Choose Color',
                        choices: _colors,
                        selectedValue: _selectedColor,
                        onSelected: (color) =>
                            setState(() => _selectedColor = color),
                        builder: (color, isSelected) => Container(
                          width: 10.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16.sp,
                                )
                              : null,
                        ),
                      ),
                    ]),
                    SizedBox(height: 3.h),
                    _buildPreviewCard(),
                    SizedBox(height: 3.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _saveReminder,
                        icon: Icon(Icons.save, size: 18.sp),
                        label: Text(
                          widget.isEdit ? "Edit Reminder" : "Save Reminder",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryDark,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 2.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildChoicePicker<T>({
    required String title,
    required List<T> choices,
    required T selectedValue,
    required Function(T) onSelected,
    required Widget Function(T, bool) builder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontSize: 15.sp),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 3.w,
          children: choices.map((value) {
            final isSelected = value == selectedValue;
            return GestureDetector(
              onTap: () => onSelected(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 0.5.w,
                  ),
                ),
                child: builder(value, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primaryDark,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Container(
                  width: 1.5.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.w),
                      bottomLeft: Radius.circular(4.w),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Icon(
                    _selectedIcon,
                    size: 18.sp,
                    color: _selectedColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? 'Reminder Title'
                            : _titleController.text,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${_selectedTime.format(context)} • $_selectedFrequency',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                          fontSize: 15.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  int generateUniqueReminderId(List<HealthReminder> reminders) {
    final random = Random();
    int id;
    final existingIds = reminders.map((r) => r.id).toSet();
    do {
      id = random.nextInt(0x7FFFFFFF);
    } while (existingIds.contains(id));
    return id;
  }

  void _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      if (widget.isEdit && widget.reminder != null) {
        await NotiServices().notificationPlugin.cancel(widget.reminder!.id);
        final updateReminder = HealthReminder(
          id: widget.reminder!.id,
          title: _titleController.text,
          time: _selectedTime,
          frequency: _selectedFrequency,
          iconName: iconToName(_selectedIcon), // ✅ FIX
          color: _selectedColor,
          isActive: widget.reminder!.isActive,
        );
        Provider.of<ReminderProvider>(
          context,
          listen: false,
        ).updateReminder(updateReminder);
        await NotiServices().reminderNoti(
          id: updateReminder.id,
          title: updateReminder.title,
          body: '${_selectedTime.format(context)} • $_selectedFrequency',
          frequency: _selectedFrequency,
          time: _selectedTime,
          color1: _selectedColor,
        );
      } else {
        final int reminderId = generateUniqueReminderId(
          _sharedprefservices.reminderList,
        );
        try {
          Provider.of<ReminderProvider>(context, listen: false).addReminder(
            HealthReminder(
              id: reminderId,
              title: _titleController.text,
              time: _selectedTime,
              frequency: _selectedFrequency,
              iconName: iconToName(_selectedIcon), // ✅ FIX
              color: _selectedColor,
              isActive: true,
            ),
          );
          await NotiServices().reminderNoti(
            id: reminderId,
            title: _titleController.text,
            body: '${_selectedTime.format(context)} • $_selectedFrequency',
            frequency: _selectedFrequency,
            time: _selectedTime,
            color1: _selectedColor,
          );
        } catch (e) {
          debugPrint(e.toString());
        }
      }
      _sharedprefservices.saveReminder();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.w),
          ),
          icon: Icon(Icons.check_circle, color: AppColors.success, size: 12.w),
          title: Text(
            widget.isEdit ? 'Reminder Edited' : 'Reminder Saved!',
            style: TextStyle(fontSize: 18.sp),
          ),
          content: Text(
            'Your reminder "${_titleController.text}" is now set.',
            style: TextStyle(fontSize: 16.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
                FocusScope.of(context).unfocus();
              },
              child: Text('OK', style: TextStyle(fontSize: 16.sp)),
            ),
          ],
        ),
      );
    } else {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _focusNode.requestFocus();
    }
  }
}
