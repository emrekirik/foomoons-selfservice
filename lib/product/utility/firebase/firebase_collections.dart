import 'package:cloud_firestore/cloud_firestore.dart';

enum FirebaseCollections {
  category,
  order,
  checkOrder;

  CollectionReference get reference =>
      FirebaseFirestore.instance.collection(name);
}
