import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



import 'bottle.dart';
import 'bottleHistoryList.dart';
import 'main.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;


class BottlePage extends StatelessWidget {
  final String? id;

  const BottlePage({Key? key,this.id }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BottleModel(),
      child: MaterialApp(

        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const MyHomePage(title: 'Bottle'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {

  final timeController = TextEditingController();
  final amountController = TextEditingController();
  String? selectedMeasure;
  final noteController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Consumer<BottleModel>(
        builder: buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, BottleModel bottleModel, _) {
    return Scaffold(
        appBar: AppBar(
         title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              showDialog(context: context, builder: (context) {
                return const MainPage();
              },
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const BottleHistoryList();
                  },
                );
              },
            ),
          ],
        ),

              body: Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
              // User input form
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                child: Column(
                children: [
                TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Time'),
                  ),
                  TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  DropdownButton<String>(
                  value: selectedMeasure,
                  onChanged: (String? newValue) {
                  setState(() {
                  selectedMeasure = newValue;
                  });
                  },
                  items: const [
                  DropdownMenuItem(
                  value: 'ml',
                  child: Text('ml'),
                  ),
                  DropdownMenuItem(
                  value: 'oz',
                  child: Text('oz'),
                  ),
                  ],
                  ),
                TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                ),
                ElevatedButton(
                onPressed: () {
                // Create a new Bottle object using the user input
                    final String bottlefeedTime = timeController.text;
                    DateTime time =
                    DateFormat('yyyy-MM-dd hh:mm a').parse(bottlefeedTime);
                    final String amount = amountController.text;
                    int intAmount = int.parse(amount);
                    final newBottle = Bottle(
                    Time: time,
                    amount: intAmount,
                    measure: selectedMeasure,
                    Note: noteController.text,
                    );

    // Add the new bottle to the BottleModel
         _firestore.collection('bottle').add(newBottle.toJson());

                  // Clear the input fields
                  timeController.clear();
                  amountController.clear();
                  selectedMeasure = null;
                  noteController.clear();
                  },
         child: const Text('Save'),
                ),
                ]
                ),
            ),
            ),
              ],
              ),
              ),
    );
  }
}
