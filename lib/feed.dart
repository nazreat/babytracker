import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

class Feed {
  late String id;
  DateTime Time;
  Duration elapsedTime;
  String selectedOption;
  String? Note;

  Feed(
      {required this.Time,
      required this.elapsedTime,
      required this.selectedOption,
      this.Note});

  Feed.fromJson(Map<String, dynamic> json, this.id)
      : Time = (json['Time'] as Timestamp).toDate(),
        elapsedTime = Duration(milliseconds: json['elapsedTime']),
        selectedOption = json['selectedOption'],
        Note = json['Note'];

  Map<String, dynamic> toJson() => {
        'Time': Time,
        'elapsedTime': elapsedTime.inMilliseconds,
        'selectedOption': selectedOption,
        'Note': Note,
      };
}

class FeedModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Feed> items = [];
  CollectionReference FeedCollection =
      FirebaseFirestore.instance.collection('Feed');
  //added this
  bool loading = false;

  //replaced this
  FeedModel() {
    fetch(); //this line won't compile until the next step
  }

  Future fetch() async {
    //clear any existing data we have gotten previously, to avoid duplicate data
    items.clear();

    //indicate that we are loading
    loading = true;
    notifyListeners(); //tell children to redraw, and they will see that the loading indicator is on

    //get all movies
    var querySnapshot = await FeedCollection.orderBy("Time").get();
    //iterate over the movies and add them to the list
    for (var doc in querySnapshot.docs) {
      //note not using the add(Movie item) function, because we don't want to add them to the db
      var feed = Feed.fromJson(doc.data()! as Map<String, dynamic>, doc.id);
      items.add(feed);
    }

    //we're done, no longer loading
    loading = false;
    update();
  }

  Feed? get(String? id) {
    if (id == null) return null;
    return items.firstWhere((feed) => feed.id == id);
  }

  void update() {
    notifyListeners();
  }

  Future delete(String id) async {
    loading = true;
    update();

    await FeedCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Future add(Feed item) async {
    loading = true;
    update();
    await FeedCollection.add(item.toJson());

    //refresh the db
    await fetch();
  }

  Future updateItem(String id, Feed item) async {
    loading = true;
    update();

    await FeedCollection.doc(id).set(item.toJson());

    //refresh the db
    await fetch();
  }
}
