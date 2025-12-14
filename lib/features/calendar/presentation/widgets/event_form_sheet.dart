import 'package:flutter/material.dart';

import '../../domain/calendar_event.dart';

class EventFormSheet extends StatefulWidget {
  const EventFormSheet({super.key, this.initialEvent, required this.onSubmit});

  final CalendarEvent? initialEvent;
  final void Function(CalendarEventDraft) onSubmit;

  @override
  State<EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<EventFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _startAt;
  DateTime? _endAt;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialEvent?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialEvent?.description ?? '');
    _startAt = widget.initialEvent?.startAt ?? DateTime.now();
    _endAt = widget.initialEvent?.endAt;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (pickedTime == null) return;

    setState(() {
      _startAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _pickEndDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endAt ?? _startAt,
      firstDate: _startAt,
      lastDate: _startAt.add(const Duration(days: 2)),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endAt ?? _startAt.add(const Duration(hours: 1))),
    );
    if (pickedTime == null) return;

    setState(() {
      _endAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final draft = CalendarEventDraft(
      title: _titleController.text.trim(),
      startAt: _startAt,
      endAt: _endAt,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
    widget.onSubmit(draft);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.initialEvent == null ? 'New event' : 'Edit event',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Start'),
              subtitle: Text('${_startAt.toLocal()}'),
              onTap: _pickStartDateTime,
            ),
            ListTile(
              leading: const Icon(Icons.event_available),
              title: const Text('End (optional)'),
              subtitle: Text(_endAt != null ? '${_endAt!.toLocal()}' : 'Not set'),
              onTap: _pickEndDateTime,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(widget.initialEvent == null ? 'Save event' : 'Update event'),
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
