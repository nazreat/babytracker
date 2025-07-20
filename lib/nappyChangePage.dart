// lib/nappyChangePage.dart

import 'dart:io';
import 'package:babytracker/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'camera.dart';
import 'nappyChangeHistrotyList.dart';
import 'nappychange.dart';

/// Theme colors matching MainPage
const Color kDarkBg1 = Color(0xFF2A2A2A);
const Color kDarkBg2 = Color(0xFF1F1F1F);
const Color kLightPink = Color(0xFFFFB6C1);
const Color kDeepPink = Color(0xFFFF69B4);

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class NappyChangePage extends StatelessWidget {
  final String? id;
  const NappyChangePage({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NappyChangeModel(),
      child: const _NappyChangeView(),
    );
  }
}

class _NappyChangeView extends StatefulWidget {
  const _NappyChangeView();
  @override
  _NappyChangeViewState createState() => _NappyChangeViewState();
}

class _NappyChangeViewState extends State<_NappyChangeView> {
  final _timeCtrl = TextEditingController();
  String? _type;
  File? _image;
  final _noteCtrl = TextEditingController();

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
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
      initialTime: TimeOfDay.fromDateTime(now),
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

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    _timeCtrl.text = DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _openCamera() async {
    final file = await Navigator.push<File?>(
      context,
      MaterialPageRoute(
        builder: (_) => const Camera(title: ''), // <-- pass a title here
      ),
    );
    if (file != null) setState(() => _image = file);
  }

  void _save() {
    if (_timeCtrl.text.isEmpty || _type == null) return;
    final dt = DateFormat('yyyy-MM-dd hh:mm a').parse(_timeCtrl.text);
    final entry = NappyChange(
      Time: dt,
      type: _type!,
      Note: _noteCtrl.text,
      image: _image?.path,
    );
    _firestore.collection('Nappies').add(entry.toJson());
    _timeCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _type = null;
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NappyChangeModel>(builder: (_, model, __) {
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
                builder: (_) => const NappyChangeHistoryList(),
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
                    // Time picker
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
                    // Type dropdown
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        filled: true,
                        fillColor: kDarkBg2,
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      dropdownColor: kDarkBg2,
                      iconEnabledColor: Colors.white70,
                      items: const [
                        DropdownMenuItem(value: 'Wet', child: Text('Wet')),
                        DropdownMenuItem(
                            value: 'Wet & Dirty', child: Text('Wet & Dirty')),
                      ],
                      onChanged: (v) => setState(() => _type = v),
                    ),
                    const SizedBox(height: 12),
                    // Note
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Note',
                        filled: true,
                        fillColor: kDarkBg2,
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Image picker buttons
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kLightPink, // button fill
                            foregroundColor:
                                Colors.white, // ← this is the text/icon color
                          ),
                          onPressed: _pickImage,
                          child: const Text('Gallery'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kLightPink,
                            foregroundColor: Colors.white,
                            // change this to whatever you like
                          ),
                          onPressed: _openCamera,
                          child: const Text('Camera'),
                        ),
                      ],
                    ),
                    if (_image != null) ...[
                      const SizedBox(height: 12),
                      Image.file(_image!, height: 200, fit: BoxFit.cover),
                    ],
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
                      borderRadius: BorderRadius.circular(8)),
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
