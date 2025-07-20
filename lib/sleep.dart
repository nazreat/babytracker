import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sleep {
  late String id;
  DateTime timeSlept;
  DateTime timeWalkup;
  String? note;

  Sleep({required this.timeSlept, required this.timeWalkup, this.note});

  Sleep.fromJson(Map<String, dynamic> json, this.id)
      : timeSlept = (json['TimeSlept'] as Timestamp).toDate(),
        timeWalkup = (json['Timewalkup'] as Timestamp).toDate(),
        note = json['Note'];

  Map<String, dynamic> toJson() =>
      {'TimeSlept': timeSlept, 'Timewalkup': timeSlept, 'Note': note};
}

class SleepModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Sleep> items = [];
  CollectionReference sleepsCollection =
      FirebaseFirestore.instance.collection('sleeps');

  //added this
  bool loading = false;

  //replaced this
  SleepModel() {
    fetch(); //this line won't compile until the next step
  }

  Future fetch() async {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all movies
    var querySnapshot = await sleepsCollection.orderBy("TimeSlept").get();

    // factory SleepModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>,document){

    // }
    //iterate over the movies and add them to the list
    for (var doc in querySnapshot.docs) {
      //note not using the add(Movie item) function, because we don't want to add them to the db
      var sleep = Sleep.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(sleep);
    }
    await Future.delayed(const Duration(seconds: 2));

    //we're done, no longer loading
    loading = false;
    update();
  }

  Sleep? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((sleep) => sleep.id == id);
  }

  void update() {
    notifyListeners();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await sleepsCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Future add(Sleep item) async {
    loading = true;
    update();
    await sleepsCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Sleep item) async {
    loading = true;
    update();

    await sleepsCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }
}
