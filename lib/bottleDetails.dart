import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'Bottle.dart';
import 'bottleHistoryList.dart';

class  BottleDetails extends StatefulWidget

{

  final String? id;
  const BottleDetails({Key? key,  this.id}) : super(key: key);

  @override

  _BottleDetailsState createState() => _BottleDetailsState();

}

class _BottleDetailsState extends State<BottleDetails> {

  final _formKey = GlobalKey<FormState>();

  final timeController = TextEditingController();

  final amountController = TextEditingController();

  final measureController = TextEditingController();

  final noteController = TextEditingController();


  @override

  Widget build(BuildContext context) {

    var bottle = Provider.of<BottleModel>(context, listen: false).get(widget.id);

    var adding = bottle == null;



    if (!adding) {

      timeController.text = DateFormat('yyyy-MM-dd hh:mm a').format(bottle.Time);

      amountController.text = bottle.amount.toString();

      measureController.text = bottle.measure.toString();

      noteController.text = bottle.Note.toString();

    }



    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: const Icon(Icons.arrow_back),

          onPressed: () {

            showDialog(

              context: context,

              builder: (context) {

                return const BottleHistoryList();

              },

            );

          },

        ),

        title: Text(adding ? "Add Bottle" : "Edit Bottle"),

      ),

      body: Padding(

        padding: const EdgeInsets.all(8),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[

            if (adding == false) Text("Bottle Index ${widget.id}"),

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

                      decoration: const InputDecoration(labelText: "Amount"),

                      controller: amountController,

                    ),

                    TextFormField(

                      decoration: const InputDecoration(labelText: "Measure"),

                      controller: measureController,

                    ),

                    TextFormField(

                      decoration: const InputDecoration(labelText: "Note"),

                      controller: noteController,

                    ),

                    ElevatedButton.icon(

                      onPressed: () async {

                        if (_formKey.currentState?.validate() ?? false) {

                          if (adding) {

                            bottle = Bottle(

                              Time: DateTime(2000, 1, 1, 0, 0, 0),

                              amount: 0,

                              measure: "",

                              Note: "",

                            );

                          }

                          final String  BottleTime = timeController.text;
                          DateTime time = DateFormat('yyyy-MM-dd hh:mm a').parse(BottleTime);
                          bottle!.Time = time;


                          bottle!.amount = int.parse(amountController.text);

                          bottle!.measure = measureController.text;

                          bottle!.Note = noteController.text;



                          if (adding) {

                            await Provider.of<BottleModel>(context, listen: false).add(bottle!);

                          } else {

                            await Provider.of<BottleModel>(context, listen: false).updateItem(widget.id!, bottle!);

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

                        int amount = int.parse(amountController.text);

                        String measure = measureController.text;

                        String note = noteController.text;

                        String message = 'Time: $time\nAmount: $amount $measure\nNote: $note';

                        Share.share(message);

                      },

                      child: const Text('Share'),

                    ),

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}
