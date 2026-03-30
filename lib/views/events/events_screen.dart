import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _eventService = EventService();
  final _authService = AuthService();
  List<Event> _events = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final events = await _eventService.getAllEvents();
      final userRole = await _authService.getUserRole();
      setState(() {
        _events = events;
        _isAdmin = (userRole == 'admin' || userRole == 'pastor');
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? const Center(child: Text('No events yet'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _showEventDetails(event),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        event.status,
                                        style:
                                            const TextStyle(fontSize: 10),
                                      ),
                                    ),
                                    if (_isAdmin)
                                      GestureDetector(
                                        onTap: () =>
                                            _showEditEventDialog(event),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 16,
                                          color: AppColors.purple,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        DateFormat('MMM d, yyyy')
                                            .format(event.date),
                                        style:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      event.time,
                                      style:
                                          const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.location,
                                        style:
                                            const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _showAddEventDialog,
              backgroundColor: AppColors.brown,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showEventDetails(Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(event.title)),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.purple),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showEditEventDialog(event);
                },
                tooltip: 'Edit',
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.event, event.type),
            const SizedBox(height: 8),
            _detailRow(Icons.calendar_today,
                DateFormat('EEEE, MMMM d, yyyy').format(event.date)),
            const SizedBox(height: 8),
            _detailRow(Icons.access_time, event.time),
            const SizedBox(height: 8),
            _detailRow(Icons.location_on, event.location),
            const SizedBox(height: 8),
            _detailRow(Icons.circle,
                event.status, color: AppColors.success),
          ],
        ),
        actions: [
          if (_isAdmin)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showDeleteEventDialog(event);
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final timeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'Service';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (e.g., 10:00 AM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    'Service',
                    'Meeting',
                    'Conference',
                    'Outreach',
                    'Social'
                  ]
                      .map((type) =>
                          DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedType = value ?? 'Service');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a title')),
                  );
                  return;
                }

                final newEvent = Event(
                  id: '',
                  title: titleController.text,
                  date: selectedDate,
                  time: timeController.text,
                  location: locationController.text,
                  type: selectedType,
                  status: 'Upcoming',
                );

                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _eventService.addEvent(newEvent);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                        content: Text('Event added successfully')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                        content: Text('Failed to add event: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventDialog(Event event) {
    final titleController = TextEditingController(text: event.title);
    final locationController =
        TextEditingController(text: event.location);
    final timeController = TextEditingController(text: event.time);
    DateTime selectedDate = event.date;
    String selectedType = event.type;
    String selectedStatus = event.status;

    const validTypes = [
      'Service',
      'Meeting',
      'Conference',
      'Outreach',
      'Social'
    ];
    const validStatuses = ['Upcoming', 'Ongoing', 'Completed', 'Cancelled'];
    if (!validTypes.contains(selectedType)) selectedType = 'Service';
    if (!validStatuses.contains(selectedStatus)) selectedStatus = 'Upcoming';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time (e.g., 10:00 AM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('MMM d, yyyy').format(selectedDate)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: validTypes
                      .map((t) =>
                          DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v ?? 'Service'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: validStatuses
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedStatus = v ?? 'Upcoming'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showDeleteEventDialog(event);
              },
              child:
                  const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final updated = event.copyWith(
                  title: titleController.text.trim(),
                  location: locationController.text.trim(),
                  time: timeController.text.trim(),
                  date: selectedDate,
                  type: selectedType,
                  status: selectedStatus,
                );
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _eventService.updateEvent(updated);
                  navigator.pop();
                  _loadData();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Event updated'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to update: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brown,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content:
            Text('Delete "${event.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _eventService.deleteEvent(event.id);
                navigator.pop();
                _loadData();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Event deleted')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
