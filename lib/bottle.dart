import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';


class Bottle
{
  late String id;
  DateTime Time;
  int amount;
  String? measure;
  String? Note;

  Bottle({ required this.Time,  required this.amount,  this.measure, this.Note });


  Bottle.fromJson(Map<String, dynamic> json, this.id)
      :
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


class BottleModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Bottle> items = [];
  CollectionReference bottleCollection = FirebaseFirestore.instance.collection(
      'bottle');



  //added this
  bool loading = false;

  //replaced this
  BottleModel() {
    fetch();
  }

  Future fetch() async
  {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all bottle
    var querySnapshot = await bottleCollection.orderBy("Time").get();
    //iterate over the bottle and add them to the list
    for (var doc in querySnapshot.docs) {
      //note not using the add(Movie item) function, because we don't want to add them to the db
      var bottle = Bottle.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(bottle);
    }



    await Future.delayed(const Duration(seconds: 2));
    loading = false;
    update();
  }



  Bottle? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((bottle) => bottle.id == id);
  }

  void update() {
    notifyListeners();
  }


  Future delete(String id) async
  {
    loading = true;
    update();

    await bottleCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Future add(Bottle item) async
  {
    loading = true;
    update();

    await bottleCollection.add(item.toJson());

    //refresh the db
    await fetch();

  }

  Future updateItem(String id, Bottle item) async
  {
    loading = true;
    update();

    await bottleCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }
}
