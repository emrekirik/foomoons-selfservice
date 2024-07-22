import 'package:cloud_firestore/cloud_firestore.dart';

enum FirebaseCollections {
  category,
  table,
  order,
  tableBill,
  checkOrder;

  CollectionReference get reference =>
      FirebaseFirestore.instance.collection(name);
}
