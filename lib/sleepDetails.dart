// lib/sleep_details.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'sleep.dart';
import 'sleepLists.dart';

/// Theme colors matching MainPage
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

class SleepDetails extends StatefulWidget {
  final String? id;
  const SleepDetails({Key? key, required this.id}) : super(key: key);

  @override
  _SleepDetailsState createState() => _SleepDetailsState();
}

class _SleepDetailsState extends State<SleepDetails> {
  final _formKey = GlobalKey<FormState>();
  final timeSleptController = TextEditingController();
  final timeWalkUpController = TextEditingController();
  final noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<SleepModel>(context, listen: false);
    var sleep = model.get(widget.id);
    final adding = sleep == null;

    if (!adding) {
      timeSleptController.text =
          DateFormat('yyyy-MM-dd hh:mm a').format(sleep!.timeSlept);
      timeWalkUpController.text =
          DateFormat('yyyy-MM-dd hh:mm a').format(sleep.timeWalkup);
      noteController.text = sleep.note ?? '';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: kDarkBg1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kLightPink,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          adding ? 'Add Sleep' : 'Edit Sleep',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Time Slept picker
            TextFormField(
              controller: timeSleptController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Time Slept',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: kDarkBg2,
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now,
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
                  initialTime: TimeOfDay.fromDateTime(now),
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

                final dt = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute);
                timeSleptController.text =
                    DateFormat('yyyy-MM-dd hh:mm a').format(dt);
              },
              validator: (v) => v!.isEmpty ? 'Select sleep time' : null,
            ),

            const SizedBox(height: 12),

            // Time Walk‑Up picker
            TextFormField(
              controller: timeWalkUpController,
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Time Walk‑Up',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: kDarkBg2,
                suffixIcon:
                    const Icon(Icons.calendar_today, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: now,
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
                  initialTime: TimeOfDay.fromDateTime(now),
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

                final dt = DateTime(
                    date.year, date.month, date.day, time.hour, time.minute);
                timeWalkUpController.text =
                    DateFormat('yyyy-MM-dd hh:mm a').format(dt);
              },
              validator: (v) => v!.isEmpty ? 'Select walk‑up time' : null,
            ),

            const SizedBox(height: 12),

            // Note field
            TextFormField(
              controller: noteController,
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

            const SizedBox(height: 24),

            // 🌸 PINK SAVE button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 32, 8, 212),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.save),
              label: const Text('Save Values'),
              onPressed: () async {
                // your save logic...
              },
            ),

            const SizedBox(height: 12),

            // 🌸 LIGHT‑PINK SHARE button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kLightPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                // your share logic...
              },
              child: const Text('Share'),
            ),
          ]),
        ),
      ),
    );
  }
}
