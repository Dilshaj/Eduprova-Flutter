import 'package:flutter/material.dart';

import '../../models/meeting_model.dart';
import '../../models/search_user_model.dart';
import '../../repository/calling_repository.dart';
import '../../widgets/participant_picker_screen.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final CallingRepository _repository = CallingRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<SearchUserModel> _participants = const [];
  DateTime _startTime = DateTime.now().add(const Duration(hours: 1));
  Duration _duration = const Duration(hours: 1);
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime),
    );
    if (time == null) return;

    setState(() {
      _startTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meeting title is required')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final meeting = await _repository.createMeeting(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        startTime: _startTime,
        endTime: _startTime.add(_duration),
        participantIds: _participants.map((user) => user.id).toList(),
      );
      if (!mounted) return;
      Navigator.of(context).pop<MeetingModel>(meeting);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to schedule meeting: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickParticipants() async {
    final result = await Navigator.of(context).push<List<SearchUserModel>>(
      MaterialPageRoute(
        builder: (_) => ParticipantPickerScreen(
          title: 'Add Participants',
          submitLabel: 'Done',
          initialSelected: _participants,
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _participants = result);
  }

  @override
  Widget build(BuildContext context) {
    final endTime = _startTime.add(_duration);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Meeting')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              title: const Text('Start'),
              subtitle: Text(_formatDateTime(_startTime)),
              trailing: const Icon(Icons.calendar_month),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Duration>(
              initialValue: _duration,
              decoration: const InputDecoration(
                labelText: 'Duration',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: Duration(minutes: 30),
                  child: Text('30 minutes'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 1),
                  child: Text('1 hour'),
                ),
                DropdownMenuItem(
                  value: Duration(hours: 2),
                  child: Text('2 hours'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _duration = value);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              title: const Text('Participants'),
              subtitle: Text(
                _participants.isEmpty
                    ? 'No participants selected'
                    : _participants.map((user) => user.displayName).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.group_add_outlined),
              onTap: _pickParticipants,
            ),
            if (_participants.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final participant in _participants)
                    InputChip(
                      label: Text(participant.displayName),
                      onDeleted: () {
                        setState(() {
                          _participants = _participants
                              .where((user) => user.id != participant.id)
                              .toList();
                        });
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Ends at ${_formatDateTime(endTime)}',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.schedule_send),
              label: Text(_submitting ? 'Scheduling...' : 'Schedule Meeting'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final timeOfDay = TimeOfDay.fromDateTime(local);
    final formattedTime = timeOfDay.format(context);
    return '${local.day}/${local.month}/${local.year} $formattedTime';
  }
}
