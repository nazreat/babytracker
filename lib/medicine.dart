import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';



class Medicine
{
  late String id;
  DateTime Time;
  int amount;
  String? measure;
  String? Note;

  Medicine({ required this.Time,  required this.amount,  this.measure, this.Note });


  Medicine.fromJson(Map<String, dynamic> json, this.id):

        Time = (json['Time'] as Timestamp).toDate(),
        amount = json['Amount'],
        measure = json['measure'],
        Note = json['Note'];

  Map<String, dynamic> toJson() =>
      {
        'Time':Time,
        'Amount': amount,
        'measure': measure,
        'Note' : Note
      };


}


class MedicineModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Medicine> items = [];
  CollectionReference medicineCollection = FirebaseFirestore.instance.collection(
      'medicine');

  //added this
  bool loading = false;

  //replaced this
  MedicineModel() {
    fetch(); //this line won't compile until the next step
  }

  Future fetch() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all movies
    var querySnapshot = await medicineCollection.orderBy("Note").get();
    //iterate over the movies and add them to the list
    for (var doc in querySnapshot.docs) {
      //note not using the add(Movie item) function, because we don't want to add them to the db
      var medicine = Medicine.fromJson(
          doc.data()! as Map<String, dynamic>, doc.id);
      items.add(medicine);
    }


    //put this line in to artificially increase the load time, so we can see the loading indicator (when we add it in a few steps time)
    //comment this out when the delay becomes annoying
    await Future.delayed(const Duration(seconds: 2));

    //we're done, no longer loading
    loading = false;
    update();
  }

  Medicine? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((medicine) => medicine.id == id);
  }

  void update() {
    notifyListeners();
  }


  Future delete(String id) async
  {
    loading = true;
    update();

    await medicineCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Future add(Medicine item) async
  {
    loading = true;
    update();

    await medicineCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Medicine item) async
  {
    loading = true;
    update();

    await medicineCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }
}