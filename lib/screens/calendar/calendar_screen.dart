import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/events_provider.dart';
import '../../models/event.dart';
import 'add_event_screen.dart';

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

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  void _goToDate(DateTime date) {
    setState(() {
      _selectedDay = date;
      _focusedDay = date;
    });
  }

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
          final allEvents = provider.events;

          return Column(
            children: [
              TableCalendar<Event>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _format,
                eventLoader: provider.eventsForDay,
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                }),
                onFormatChanged: (f) => setState(() => _format = f),
                onPageChanged: (focused) => _focusedDay = focused,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
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
              // Scrollable events list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    // ---- Events on selected day ----
                    if (selectedEvents.isNotEmpty) ...
                        _buildSection(
                          context,
                          icon: Icons.today,
                          title:
                              'On ${DateFormat('MMM d').format(_selectedDay)} (${selectedEvents.length})',
                          color: Theme.of(context).colorScheme.primary,
                          events: selectedEvents,
                          provider: provider,
                          onTap: null, // already on this date
                        ),

                    // ---- All events ----
                    _SectionHeader(
                      icon: Icons.calendar_month,
                      title: 'All Events (${allEvents.length})',
                      color: Colors.grey.shade700,
                    ),
                    if (allEvents.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No events yet. Tap + to add one!',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ...allEvents.map(
                        (e) => _EventTile(
                          event: e,
                          provider: provider,
                          // Tap to navigate calendar to that date
                          onTap: () => _goToDate(e.date),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<Event> events,
    required EventsProvider provider,
    required VoidCallback? onTap,
  }) {
    return [
      _SectionHeader(icon: icon, title: title, color: color),
      ...events.map(
        (e) => _EventTile(event: e, provider: provider, onTap: onTap),
      ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;
  final EventsProvider provider;
  final VoidCallback? onTap;

  const _EventTile({
    required this.event,
    required this.provider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');
    final color = _typeColors[event.type] ?? Colors.purple;
    return Dismissible(
      key: Key('evt_${event.id}'),
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
          onTap: onTap,
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
