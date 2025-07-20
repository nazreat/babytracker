// lib/feed_page.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottlePage.dart';
import 'feedingHistoryList.dart';
import 'feed.dart';
import 'main.dart';

/// Theme colors matching MainPage
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedModel(),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView({Key? key}) : super(key: key);
  @override
  FeedViewState createState() => FeedViewState();
}

class FeedViewState extends State<_FeedView> {
  final _formKey = GlobalKey<FormState>();
  final _timeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _side;
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _displayTime = '00:00:00';
  DateTime? _pickedTime;

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _displayTime = _format(_stopwatch.elapsed));
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  void _resetTimer() {
    _stopwatch.reset();
    setState(() => _displayTime = '00:00:00');
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedTime ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: kDeepPink,
            onPrimary: Colors.white,
            surface: kDarkBg2,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: kDarkBg1,
        ),
        child: child!,
      ),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickedTime ?? now),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: kDarkBg1,
            hourMinuteColor: kDarkBg2,
            hourMinuteTextColor: Colors.white,
            dialHandColor: kDeepPink,
            dialBackgroundColor: kDarkBg2,
            dayPeriodTextColor: Colors.white70,
            entryModeIconColor: kLightPink,
          ),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    final dt =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    _pickedTime = dt;
    _timeCtrl.text = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final feed = Feed(
      Time: _pickedTime!,
      elapsedTime: _stopwatch.elapsed,
      selectedOption: _side!,
      Note: _noteCtrl.text,
    );
    _firestore.collection('Feed').add(feed.toJson());
    _formKey.currentState!.reset();
    _timeCtrl.clear();
    _noteCtrl.clear();
    _resetTimer();
    setState(() => _side = null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kDarkBg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: kLightPink,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const FeedingHistoryList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kDeepPink,
        child: const Icon(Icons.local_drink),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const BottlePage(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).size.height * 0.2, // pushes content down
          16,
          16,
        ),
        child: Form(
          key: _formKey,
          child: Card(
            color: kDarkBg2,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Date & time picker
                  TextFormField(
                    controller: _timeCtrl,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Feeding Time',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: kDarkBg2,
                      suffixIcon: const Icon(Icons.calendar_today,
                          color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (v) =>
                        v != null && v.isNotEmpty ? null : 'Select time',
                    onTap: _pickDateTime,
                  ),

                  const SizedBox(height: 16),

                  // Side + timer display
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _side,
                          decoration: InputDecoration(
                            labelText: 'Side',
                            labelStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: kDarkBg2,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: kDarkBg2,
                          iconEnabledColor: Colors.white70,
                          items: const [
                            DropdownMenuItem(
                                value: 'Right', child: Text('Right')),
                            DropdownMenuItem(
                                value: 'Left', child: Text('Left')),
                          ],
                          onChanged: (v) => setState(() => _side = v),
                          validator: (v) => v != null ? null : 'Select side',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _displayTime,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Timer controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kDeepPink),
                        onPressed: _startTimer,
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kDeepPink),
                        onPressed: _stopTimer,
                        child: const Text('Stop'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kDeepPink),
                        onPressed: _resetTimer,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Note field
                  TextFormField(
                    controller: _noteCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Note',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: kDarkBg2,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  // 🌸 Small pink Save button
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDeepPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      minimumSize: const Size(150, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
