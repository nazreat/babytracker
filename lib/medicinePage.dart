// lib/medicinePage.dart

import 'package:babytracker/medicineHistoryList.dart';
import 'package:babytracker/main.dart';
import 'package:babytracker/Medicine.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Theme colors matching MainPage
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MedicinePage extends StatelessWidget {
  final String? id;
  const MedicinePage({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineModel(),
      child: const _MedicineView(),
    );
  }
}

class _MedicineView extends StatefulWidget {
  const _MedicineView();
  @override
  _MedicineViewState createState() => _MedicineViewState();
}

class _MedicineViewState extends State<_MedicineView> {
  final _timeCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _measure;
  DateTime? _pickedTime;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedTime ?? now,
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
      initialTime: TimeOfDay.fromDateTime(_pickedTime ?? now),
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
    _pickedTime = dt;
    _timeCtrl.text = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  void _save() {
    if (_pickedTime == null || _measure == null || _amountCtrl.text.isEmpty)
      return;
    final med = Medicine(
      Time: _pickedTime!,
      amount: int.tryParse(_amountCtrl.text) ?? 0,
      measure: _measure!,
      Note: _noteCtrl.text,
    );
    _firestore.collection('medicine').add(med.toJson());
    _timeCtrl.clear();
    _amountCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _pickedTime = null;
      _measure = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineModel>(builder: (_, model, __) {
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
                builder: (_) => const MedicineHistroyList(),
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
                    TextFormField(
                      controller: _timeCtrl,
                      readOnly: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Time',
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
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: kDarkBg2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _measure,
                      decoration: InputDecoration(
                        labelText: 'Measure',
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
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'oz', child: Text('oz')),
                      ],
                      onChanged: (v) => setState(() => _measure = v),
                    ),
                    const SizedBox(height: 12),
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
