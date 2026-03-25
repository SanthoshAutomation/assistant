import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEventScreen(initialDate: _selectedDay),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: Consumer<EventsProvider>(
        builder: (context, provider, _) {
          final selectedEvents = provider.eventsForDay(_selectedDay);

          return Column(
            children: [
              TableCalendar<Event>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _format,
                eventLoader: provider.eventsForDay,
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onFormatChanged: (f) => setState(() => _format = f),
                onPageChanged: (focused) => _focusedDay = focused,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(_selectedDay),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      '${selectedEvents.length} event${selectedEvents.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selectedEvents.isEmpty
                    ? const Center(
                        child: Text('No events on this day',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, i) =>
                            _EventTile(event: selectedEvents[i], provider: provider),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

const _typeColors = {
  EventType.appointment: Colors.blue,
  EventType.vacation: Colors.green,
  EventType.reminder: Colors.orange,
  EventType.other: Colors.purple,
};

const _typeIcons = {
  EventType.appointment: Icons.medical_services_outlined,
  EventType.vacation: Icons.beach_access_outlined,
  EventType.reminder: Icons.alarm,
  EventType.other: Icons.event_outlined,
};

class _EventTile extends StatelessWidget {
  final Event event;
  final EventsProvider provider;
  const _EventTile({required this.event, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('h:mm a');
    final color = _typeColors[event.type] ?? Colors.purple;
    return Dismissible(
      key: Key(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.delete(event.id),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(_typeIcons[event.type], color: color, size: 20),
          ),
          title: Text(event.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.endDate != null
                    ? '${fmt.format(event.date)} \u2192 ${DateFormat('MMM d').format(event.endDate!)}'
                    : fmt.format(event.date),
                style: const TextStyle(fontSize: 12),
              ),
              if (event.notes != null && event.notes!.isNotEmpty)
                Text(event.notes!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              event.type.name,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
