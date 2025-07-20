import 'package:babytracker/medicineHistoryList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'Medicine.dart';
import 'package:intl/intl.dart';


class  MedicineDetails extends StatefulWidget

{
  final String? id;
  const MedicineDetails({Key? key,  this.id}) : super(key: key);

  @override

  _MedicineDetailsState createState() => _MedicineDetailsState();

}



class _MedicineDetailsState extends State<MedicineDetails> {

  final _formKey = GlobalKey<FormState>();

  final timeController = TextEditingController();

  final amountController = TextEditingController();

  final measureController = TextEditingController();

  final noteController = TextEditingController();



  @override

  void dispose() {

    timeController.dispose();

    amountController.dispose();

    measureController.dispose();

    noteController.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    var medicine = Provider.of<MedicineModel>(context, listen: false).get(widget.id);

    var adding = medicine == null;



    if (!adding) {

      timeController.text = DateFormat('yyyy-MM-dd hh:mm a').format(medicine.Time);

      amountController.text = medicine.amount.toString();

      measureController.text = medicine.measure.toString();

      noteController.text = medicine.Note.toString();

    }



    return Scaffold(

      appBar: AppBar(

        leading: IconButton(

          icon: Icon(Icons.arrow_back),

          onPressed: () {

            showDialog(

              context: context,

              builder: (context) {

                return const MedicineHistroyList();

              },

            );

          },

        ),

        title: Text(adding ? "Add Medicine" : "Edit Medicine"),

      ),

      body: Padding(

        padding: const EdgeInsets.all(8),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.start,

          children: <Widget>[

            if (adding == false) Text("Medicine Index ${widget.id}"),

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

                            medicine = Medicine(

                              Time: DateTime(2000, 1, 1, 0, 0, 0),

                              amount: 0,

                              measure: "",

                              Note: "",

                            );

                          }

                          final String medicineTime = timeController.text;
                          DateTime time = DateFormat('yyyy-MM-dd hh:mm a').parse(medicineTime);
                          medicine!.Time = time;


                          medicine!.amount = int.parse(amountController.text);

                          medicine!.measure = measureController.text;

                          medicine!.Note = noteController.text;



                          if (adding) {

                            await Provider.of<MedicineModel>(context, listen: false).add(medicine!);

                          } else {

                            await Provider.of<MedicineModel>(context, listen: false).updateItem(widget.id!, medicine!);

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

                      child: Text('Share'),

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

