// lib/sleepPage.dart

import 'package:babytracker/sleepLists.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';
import 'sleep.dart';

/// Theme colors matching MainPage
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SleepPage extends StatelessWidget {
  final String? id;
  const SleepPage({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SleepModel(),
      child: const _SleepView(),
    );
  }
}

class _SleepView extends StatefulWidget {
  const _SleepView();
  @override
  _SleepViewState createState() => _SleepViewState();
}

class _SleepViewState extends State<_SleepView> {
  final _sleptCtrl = TextEditingController();
  final _wakeCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime? _sleptAt, _wokeAt;

  Future<void> _pickDatetime(
    TextEditingController ctrl,
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
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
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
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
    ctrl.text = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
    onPicked(dt);
  }

  void _save() {
    final sl = DateFormat('yyyy-MM-dd hh:mm a').parse(_sleptCtrl.text);
    final wk = DateFormat('yyyy-MM-dd hh:mm a').parse(_wakeCtrl.text);
    final entry = Sleep(timeSlept: sl, timeWalkup: wk, note: _noteCtrl.text);
    _firestore.collection('sleeps').add(entry.toJson());

    _sleptCtrl.clear();
    _wakeCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _sleptAt = _wokeAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SleepModel>(builder: (_, model, __) {
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
                builder: (_) => const SleepPage(),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Time Slept
                    TextFormField(
                      controller: _sleptCtrl,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Time Slept',
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
                      onTap: () => _pickDatetime(
                          _sleptCtrl, _sleptAt, (d) => _sleptAt = d),
                    ),

                    const SizedBox(height: 12),

                    // Time Woke Up
                    TextFormField(
                      controller: _wakeCtrl,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Time Woke Up',
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
                      onTap: () =>
                          _pickDatetime(_wakeCtrl, _wokeAt, (d) => _wokeAt = d),
                    ),

                    const SizedBox(height: 12),

                    // Note
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
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
                    ),
                  ],
                ),
              ),

              // 🌸 Small pink Save button
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDeepPink,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      );
    });
  }
}
