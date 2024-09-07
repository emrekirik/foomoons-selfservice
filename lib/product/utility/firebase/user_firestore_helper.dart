import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFirestoreHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  /// Get the reference to the user-specific collection for any given type (categories, products, etc.)
  CollectionReference getUserCollection(String collectionName) {
    if (currentUser == null) {
      throw Exception('No authenticated user');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection(collectionName);
  }

  /// Get a specific document reference from a user-specific collection
  DocumentReference getUserDocument(String collectionName, String documentId) {
    return getUserCollection(collectionName).doc(documentId);
  }
}
