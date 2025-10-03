import 'dart:math';
import 'package:demo_health/Models/reminders.dart';
import 'package:demo_health/Services/SharedPrefServices.dart';
import 'package:demo_health/Theme/AppTheme.dart';
// import 'package:demo_health/notiServices/noti_Services.dart';
import 'package:demo_health/provider/reminderPRO.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../notiServices/noti_Services.dart';

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
    Colors.purple.shade300,
    Colors.teal.shade300,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _selectedFrequency = widget.reminder!.frequency;
      _selectedTime = widget.reminder!.time ?? TimeOfDay.now();
      _selectedColor = widget.reminder!.color;
      _selectedIcon = widget.reminder!.icon;
    }
    _sharedprefservices.getReminder();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    // final remindersProvider = Provider.of<ReminderProvider>(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => unFocus(),
      child: Scaffold(
        appBar: AppBar(
          title: widget.isEdit
              ? const Text("Edit Reminder")
              : const Text('New Reminder'),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
                vertical: 16.0,
              ),
              children: [
                _buildCard('Details', [
                  TextFormField(
                    controller: _titleController,
                    focusNode: _focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Reminder Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter a title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    items: _frequencies
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedFrequency = value!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.access_time,
                      color: AppColors.primary,
                    ),
                    title: const Text('Select Time'),
                    subtitle: Text(
                      _selectedTime.format(context),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    onTap: _selectTime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildCard('Icon & Color', [
                  _buildChoicePicker<IconData>(
                    title: 'Choose Icon',
                    choices: _icons,
                    selectedValue: _selectedIcon,
                    onSelected: (icon) => setState(() => _selectedIcon = icon),
                    builder: (icon, isSelected) => Icon(
                      icon,
                      color: isSelected ? AppColors.primary : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildChoicePicker<Color>(
                    title: 'Choose Color',
                    choices: _colors,
                    selectedValue: _selectedColor,
                    onSelected: (color) =>
                        setState(() => _selectedColor = color),
                    builder: (color, isSelected) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildPreviewCard(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15.0,
                    left: 20,
                    right: 20,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _saveReminder,
                    icon: const Icon(Icons.save),
                    label: widget.isEdit
                        ? const Text("Edit Reminder")
                        : const Text('Save Reminder'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 16),
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
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: choices.map((value) {
            final isSelected = value == selectedValue;
            return GestureDetector(
              onTap: () => onSelected(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _selectedColor,
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
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_selectedIcon, size: 32, color: _selectedColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleController.text.isEmpty
                            ? 'Reminder Title'
                            : _titleController.text,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_selectedTime.format(context)} • $_selectedFrequency',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
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
      id = random.nextInt(0x7FFFFFFF); // 32-bit positive int
    } while (existingIds.contains(id));
    return id;
  }

  void _saveReminder() async {
    print("_saveReminder called");
    if (_formKey.currentState!.validate()) {
      if (widget.isEdit && widget.reminder != null) {
        await NotiServices().notificationPlugin.cancel(widget.reminder!.id);
        final updateReminder = HealthReminder(
          id: widget.reminder!.id,
          title: _titleController.text,
          time: _selectedTime,
          frequency: _selectedFrequency,
          icon: _selectedIcon,
          color: _selectedColor,
          isActive: widget.reminder!.isActive,
        );
        Provider.of<ReminderProvider>(
          context,
          listen: false,
        ).updateReminder(updateReminder);
        // ignore: unnecessary_null_comparison
        if (_selectedTime != null) {
          await NotiServices().reminderNoti(
            id: updateReminder.id,
            title: updateReminder.title,
            body: '${_selectedTime.format(context)} • $_selectedFrequency',
            frequency: _selectedFrequency,
            time: _selectedTime,
            color1: _selectedColor,
          );
        }
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
              icon: _selectedIcon,
              color: _selectedColor,
              isActive: true,
            ),
          );

          // ignore: unnecessary_null_comparison
          if (_selectedTime != null) {
            await NotiServices().reminderNoti(
              id: reminderId,
              title: _titleController.text,
              body: '${_selectedTime.format(context)} • $_selectedFrequency',
              frequency: _selectedFrequency,
              time: _selectedTime,
              color1: _selectedColor,
            );
          }
        } catch (e) {
          print(e.toString());
        }
      }

      // setState(() {
      //   _sharedprefservices.reminderList.add(
      //     HealthReminder(
      //       id: reminderId,
      //       title: _titleController.text,
      //       time: _selectedTime,
      //       frequency: _selectedFrequency,
      //       icon: _selectedIcon,
      //       color: _selectedColor,
      //     ),
      //   );
      // });

      // print(reminderId.toString());

      _sharedprefservices.saveReminder();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 60,
          ),
          title: widget.isEdit
              ? const Text('Reminder Edited')
              : const Text('Reminder Saved!'),
          content: Text('Your reminder "${_titleController.text}" is now set.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(true);
                FocusScope.of(context).unfocus();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        // curve: Curves.easeInCubic,
        curve: Curves.easeInOut,
      );
      _focusNode.requestFocus();
    }
  }
}
