import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/calendar_controller.dart';
import '../domain/calendar_event.dart';
import 'widgets/event_form_sheet.dart';

class CalendarDayScreen extends ConsumerWidget {
  const CalendarDayScreen({super.key});

  void _openForm(BuildContext context, WidgetRef ref, {CalendarEvent? event}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EventFormSheet(
        initialEvent: event,
        onSubmit: (draft) {
          final controller = ref.read(calendarControllerProvider.notifier);
          if (event == null) {
            controller.addEvent(draft);
          } else {
            controller.updateEvent(event, draft);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarControllerProvider);
    final controller = ref.read(calendarControllerProvider.notifier);

    final events = [...state.events]
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            tooltip: state.isOffline ? 'Offline mode' : 'Go offline',
            icon: Stack(
              children: <Widget>[
                Icon(state.isOffline ? Icons.cloud_off : Icons.cloud_queue),
                if (state.pendingOperations.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      child: Text(
                        state.pendingOperations.length.toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: controller.toggleOfflineMode,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.event),
        label: const Text('Add event'),
        onPressed: () => _openForm(context, ref),
      ),
      body: Column(
        children: <Widget>[
          if (state.errorMessage != null)
            MaterialBanner(
              content: Text(state.errorMessage!),
              leading: const Icon(Icons.error_outline),
              actions: <Widget>[
                TextButton(
                  onPressed: controller.clearError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          if (state.pendingOperations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.sync_problem_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Queued: ${state.pendingOperations.length} changes waiting for connection',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (!state.isOffline)
                    TextButton(
                      onPressed: controller.syncPending,
                      child: const Text('Sync now'),
                    ),
                ],
              ),
            ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : events.isEmpty
                    ? const _EmptyCalendar()
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: ListTile(
                              title: Text(event.title),
                              subtitle: Text(_formatRange(context, event)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => controller.deleteEvent(event),
                              ),
                              onTap: () => _openForm(context, ref, event: event),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatRange(BuildContext context, CalendarEvent event) {
    final start = event.startAt.toLocal();
    final end = event.endAt?.toLocal();
    final startTime = TimeOfDay.fromDateTime(start).format(context);
    final startDate = _formatDate(start);
    if (end == null) {
      return '$startDate • $startTime';
    }
    final endTime = TimeOfDay.fromDateTime(end).format(context);
    final endDate = _formatDate(end);
    return '$startDate – $endDate\n$startTime - $endTime';
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _EmptyCalendar extends StatelessWidget {
  const _EmptyCalendar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.event_busy, size: 64),
          const SizedBox(height: 12),
          Text(
            'No events scheduled',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Create your first event to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
