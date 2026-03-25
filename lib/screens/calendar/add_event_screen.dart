import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime initialDate;
  const AddEventScreen({super.key, required this.initialDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  late DateTime _date;
  DateTime? _endDate;
  EventType _type = EventType.other;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({bool isEnd = false}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? _date) : _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isEnd ? (_endDate ?? _date) : _date),
    );
    if (time == null || !mounted) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isEnd) {
        _endDate = dt;
      } else {
        _date = dt;
      }
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    await context.read<EventsProvider>().add(
          title: title,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          date: _date,
          endDate: _endDate,
          type: _type,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, MMM d \u2022 h:mm a');
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Event title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Type selector
            const Text('Event type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: EventType.values
                  .map((t) => ChoiceChip(
                        label: Text(t.name),
                        selected: _type == t,
                        onSelected: (_) => setState(() => _type = t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            // Start date
            _DateTile(
              label: 'Start',
              value: fmt.format(_date),
              onTap: () => _pickDate(),
            ),
            const SizedBox(height: 8),
            // End date (optional)
            _DateTile(
              label: _endDate == null ? 'Add end date (vacation/multi-day)' : 'End',
              value: _endDate != null ? fmt.format(_endDate!) : null,
              onTap: () => _pickDate(isEnd: true),
              trailing: _endDate != null
                  ? GestureDetector(
                      onTap: () => setState(() => _endDate = null),
                      child: const Icon(Icons.close, size: 16),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DateTile({
    required this.label,
    this.value,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
