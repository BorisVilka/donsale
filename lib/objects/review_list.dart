
import 'package:Donsale/objects/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewList {

  List<Review> list;

  ReviewList({required this.list});

  factory ReviewList.fromFirestore(
      DocumentSnapshot<Map<String,dynamic>> snapshot,
      SnapshotOptions? options
      ) {
    var data = snapshot.data();
    return ReviewList(
        list: List<Review>.from(((data?['list'] ?? []) as List<dynamic>).map((e) => Review.fromFirestore(e)).toList())
    );
  }


  Map<String,dynamic> toFirestore() {
    return {
      'list': List<dynamic>.from(list.map((e) => e.toFirestore())),
    };
  }
}