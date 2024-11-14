import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<T>> fetchCollection<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
  }

  Future<T?> fetchDocument<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final doc = await _firestore.doc(path).get();
    if (!doc.exists) return null;
    return fromJson(doc.data()!);
  }

  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    await _firestore.doc(path).update(data);
  }

  Future<void> deleteDocument(String path) async {
    await _firestore.doc(path).delete();
  }
}
