import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';



class NappyChange
{
  late String id;
  DateTime Time;
  String? type;
  String? Note;
  String? image;

  NappyChange({  required this.Time,   this.type, this.Note,  this.image });


  NappyChange.fromJson(Map<String, dynamic> json, this.id)
      :
        Time = (json['Time'] as Timestamp).toDate(),
        type = json['Nappy Type'],
        Note = json['Note'],
        image = json['Image'];



  Map<String, dynamic> toJson() =>
      {
        'Time':Time,
        'Nappy type': type,
        'Note' : Note,
        'Image': image,

      };


}
class NappyChangeModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<NappyChange> items = [];
  CollectionReference NappiesCollection = FirebaseFirestore.instance.collection(
      'Nappies');



  //added this
  bool loading = false;

  //replaced this
  NappyChangeModel() {
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
    var querySnapshot = await NappiesCollection.orderBy("Time").get();
    //iterate over the movies and add them to the list
    for (var doc in querySnapshot.docs) {
      //note not using the add(Movie item) function, because we don't want to add them to the db
      var nappy = NappyChange.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(nappy);
    }
    //put this line in to artificially increase the load time, so we can see the loading indicator (when we add it in a few steps time)
    //comment this out when the delay becomes annoying
    await Future.delayed(const Duration(seconds: 2));

    //we're done, no longer loading
    loading = false;
    update();
  }



  NappyChange? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((nappy) => nappy.id == id);
  }

  void update() {
    notifyListeners();
  }


  Future delete(String id) async
  {
    loading = true;
    update();
    await NappiesCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Future add(NappyChange item) async
  {
    loading = true;
    update();

    await NappiesCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, NappyChange item) async
  {
    loading = true;
    update();

    await NappiesCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }
}
