import 'package:babytracker/nappyChangeHistrotyList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'nappychange.dart';
import 'package:intl/intl.dart';

class NappyChangeDetails extends StatefulWidget {
  final String? id;

  const NappyChangeDetails({Key? key, this.id}) : super(key: key);

  @override
  _NappyChangeDetailsState createState() => _NappyChangeDetailsState();
}

class _NappyChangeDetailsState extends State<NappyChangeDetails> {
  final _formKey = GlobalKey<FormState>();
  final timeController = TextEditingController();
  String? selectedType;
  final noteController = TextEditingController();
  final selectedOptionController = TextEditingController();

  @override
  void dispose() {
    timeController.dispose();
    selectedOptionController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var nappy =
    Provider.of<NappyChangeModel>(context, listen: false).get(widget.id);
    var adding = nappy == null;
    if (!adding) {
      timeController.text =
          DateFormat('yyyy-MM-dd hh:mm a').format(nappy.Time);
      selectedOptionController.text = nappy.type.toString();
      noteController.text = nappy.Note.toString();
      selectedType = nappy.type; // Set selectedType to the initial value
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return const NappyChangeHistoryList();
              },
            );
          },
        ),
        title: Text(adding ? "Add Nappy" : "Edit Nappy"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (adding == false) Text("Nappy Index ${widget.id}"),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Time"),
                      controller: timeController,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Type"),
                      controller: selectedOptionController, // Assign controller here
                      onChanged: (value) {
                        setState(() {
                          selectedType = value; // Update selectedType on change
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: selectedType,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue;
                          selectedOptionController.text = newValue ?? '';
                        });
                      },
                      items: <String>['Wet', 'Wet&Dirrty']
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
                            nappy = NappyChange(
                              Time: DateTime(0, 1, 1, 0, 0, 0),
                              type: "",
                              Note: "",
                            );
                          }

                          final String nappyTime = timeController.text;
                          DateTime time =
                          DateFormat('yyyy-MM-dd hh:mm a').parse(nappyTime);
                          nappy!.Time = time;
                          nappy!.type = selectedOptionController.text; // Use selectedType
                          nappy!.Note = noteController.text;

                          if (adding) {
                            await Provider.of<NappyChangeModel>(context,
                                listen: false)
                                .add(nappy!);
                          } else {
                            await Provider.of<NappyChangeModel>(context,
                                listen: false)
                                .updateItem(widget.id!, nappy!);
                          }

                          // Return to the previous screen
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Save Values"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String time = timeController.text;
                        String type = selectedOptionController.text;
                        String note = noteController.text;
                        String message = 'Time: $time\nType: $type\nNote: $note';
                        Share.share(message);
                      },
                      child: Text('Share'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
