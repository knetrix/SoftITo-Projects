import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';

class HabitFormView extends StatefulWidget {
  final HabitModel? initialHabit;
  final void Function(
    String title,
    String description,
    String category,
    String frequency,
    String? reminderTime,
  ) onSave;

  const HabitFormView({
    super.key,
    this.initialHabit,
    required this.onSave,
  });

  @override
  State<HabitFormView> createState() => _HabitFormViewState();
}

class _HabitFormViewState extends State<HabitFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedCategory;
  late String _selectedFrequency;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialHabit?.title ?? '');
    _descController = TextEditingController(text: widget.initialHabit?.description ?? '');
    _selectedCategory = widget.initialHabit?.category ?? AppConstants.categories.first;
    _selectedFrequency = widget.initialHabit?.frequency ?? AppConstants.frequencies.first;

    if (widget.initialHabit?.reminderTime != null) {
      final parts = widget.initialHabit!.reminderTime!.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    String? reminderStr;
    if (_reminderTime != null) {
      final h = _reminderTime!.hour.toString().padLeft(2, '0');
      final m = _reminderTime!.minute.toString().padLeft(2, '0');
      reminderStr = '$h:$m';
    }

    widget.onSave(
      _titleController.text,
      _descController.text,
      _selectedCategory,
      _selectedFrequency,
      reminderStr,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialHabit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? AppStrings.editHabit : AppStrings.addHabit),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _submit),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: _buildFormContent(isEditing),
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isEditing) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleField(),
          const SizedBox(height: 16),
          _buildDescField(),
          const SizedBox(height: 16),
          _buildCategoryDropdown(),
          const SizedBox(height: 16),
          _buildFrequencyDropdown(),
          const SizedBox(height: 16),
          _buildReminderPicker(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submit,
            child: Text(isEditing ? AppStrings.saveChanges : AppStrings.createHabit),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      validator: (v) => AppValidators.validateNotEmpty(v, AppStrings.habitTitleLabel),
      decoration: InputDecoration(
        labelText: AppStrings.habitTitleLabel,
        hintText: AppStrings.habitTitleHint,
        prefixIcon: const Icon(Icons.edit_note_rounded),
      ),
    );
  }

  Widget _buildDescField() {
    return TextFormField(
      controller: _descController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: AppStrings.habitDescLabel,
        hintText: AppStrings.habitDescHint,
        prefixIcon: const Icon(Icons.description_outlined),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: AppStrings.habitCategoryLabel,
        prefixIcon: const Icon(Icons.category_outlined),
      ),
      items: AppConstants.categories.map((cat) {
        return DropdownMenuItem(value: cat, child: Text(cat));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedCategory = val);
      },
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedFrequency,
      decoration: InputDecoration(
        labelText: AppStrings.habitFrequencyLabel,
        prefixIcon: const Icon(Icons.repeat_rounded),
      ),
      items: AppConstants.frequencies.map((freq) {
        return DropdownMenuItem(value: freq, child: Text(freq));
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedFrequency = val);
      },
    );
  }

  Widget _buildReminderPicker() {
    final timeText = _reminderTime != null
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : AppStrings.timeNotSelected;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
      ),
      leading: const Icon(Icons.access_time_rounded),
      title: Text(AppStrings.habitTimeLabel),
      subtitle: Text(timeText),
      trailing: _reminderTime != null
          ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => setState(() => _reminderTime = null),
            )
          : const Icon(Icons.chevron_right),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
        );
        if (picked != null) setState(() => _reminderTime = picked);
      },
    );
  }
}
