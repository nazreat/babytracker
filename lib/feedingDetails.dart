import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'feed.dart';
import 'feedingHistoryList.dart';

class FeedDetails extends StatefulWidget {
  final String? id;
  const FeedDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<FeedDetails> createState() => _FeedDetailsState();
}

class _FeedDetailsState extends State<FeedDetails> {
  final _formKey = GlobalKey<FormState>();
  final timeController = TextEditingController();
  final durationController = TextEditingController();
  final selectedOptionController = TextEditingController();
  final noteController = TextEditingController();
  Stopwatch _stopwatch = Stopwatch();
  Timer? timer;
  String _elapsedTime = '00:00:00';

  String? selectedOption;

  void _startTimer() {
    _stopwatch.start();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedTime = _getFormattedTime(_stopwatch.elapsed);
      });
    });
  }

  void _resetTimer() {
    _stopwatch.reset();

    setState(() {
      _elapsedTime = '00:00:00';
    });
  }

  void _stopTimer() {
    _stopwatch.stop();

    timer?.cancel();
  }

  String _getFormattedTime(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";

      return "0$n";
    }

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _stopwatch.stop();
    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var feed = Provider.of<FeedModel>(context, listen: false).get(widget.id);

    var adding = feed == null;
    if (!adding) {
      timeController.text = DateFormat('yyyy-MM-dd hh:mm a').format(feed.Time);
      durationController.text = feed.elapsedTime.toString();
      selectedOptionController.text = feed.selectedOption.toString();
      noteController.text = feed.Note.toString();
      selectedOption = feed.selectedOption;
    } else if (selectedOption == null) {
      selectedOption = 'Right';
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const FeedingHistoryList();
              },
            );
          },
        ),
        title: Text(adding ? "Add Feed" : "Edit Feed"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (adding == false) Text("Feed Index ${widget.id}"),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Time"),
                        controller: timeController,
                        autofocus: true,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: " Duration "),
                        controller: durationController,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: "Selected option"),
                        controller: selectedOptionController,
                      ),
                      DropdownButton<String>(
                        value: selectedOption,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedOption = newValue;
                            selectedOptionController.text = newValue ?? '';
                          });
                        },
                        items: <String>['Right', 'Left']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: "Note"),
                        controller: noteController,
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            if (adding) {
                              feed = Feed(
                                Time: DateTime(0, 1, 1, 0, 0, 0),
                                elapsedTime:
                                    Duration(hours: 0, minutes: 0, seconds: 0),
                                selectedOption: "",
                                Note: "",
                              );
                            }

                            final String feedTime = timeController.text;
                            DateTime time = DateFormat('yyyy-MM-dd hh:mm a')
                                .parse(feedTime);
                            feed!.Time = time;
                            feed!.elapsedTime = _stopwatch.elapsed;
                            feed!.selectedOption =
                                selectedOptionController.text;
                            feed!.Note = noteController.text;

                            if (adding) {
                              await Provider.of<FeedModel>(context,
                                      listen: false)
                                  .add(feed!);
                            } else {
                              await Provider.of<FeedModel>(context,
                                      listen: false)
                                  .updateItem(widget.id!, feed!);
                            }

                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Save Values"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String time = timeController.text;
                          Duration elapsedTime = _stopwatch.elapsed;
                          String selectedOption = selectedOptionController.text;
                          String note = noteController.text;
                          String message =
                              'Time: $time\nElapsed Time: $elapsedTime\nSelected Option: $selectedOption\nNote: $note';
                          Share.share(message);
                        },
                        child: const Text('Share'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
