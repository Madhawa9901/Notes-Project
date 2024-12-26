import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  // Firestore collection references
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');

  // Create
  Future<void> addNote(String note, String title,
      {List<String>? imageURLs, List<String>? documentURLs}) {
    return notes.add({
      'title': title,
      'note': note,
      'imageURLs': imageURLs ?? [], // Store as a list of URLs
      'documentURLs': documentURLs ?? [], // Store as a list of URLs
      'timestamp': Timestamp.now(),
    });
  }

  // Read
  Stream<QuerySnapshot> getNotesStream() {
    return notes.orderBy('timestamp', descending: true).snapshots();
  }

  // Update
  Future<void> updateNote(String docID, String newNote, String newTitle,
      {List<String>? imageURLs, List<String>? documentURLs}) {
    return notes.doc(docID).update({
      'note': newNote,
      'title': newTitle,
      'imageURLs': imageURLs ?? [], // Update with a list of image URLs
      'documentURLs': documentURLs ?? [], // Update with a list of document URLs
      'timestamp': Timestamp.now(),
    });
  }

  // Delete
  Future<void> deleteNote(String docID,
      {List<String>? imageURLs, List<String>? documentURLs}) async {
    try {
      // Delete the note document
      await notes.doc(docID).delete();
      print("Note deleted successfully");

      // Function to delete files from Firebase Storage
      Future<void> deleteFileFromStorage(String fileUrl) async {
        try {
          final ref = FirebaseStorage.instance.refFromURL(fileUrl);
          await ref.delete();
          print("File deleted from storage: $fileUrl");
        } catch (e) {
          print("Error deleting file: $fileUrl - $e");
        }
      }

      // Delete associated images from Firebase Storage
      if (imageURLs != null && imageURLs.isNotEmpty) {
        for (String imageUrl in imageURLs) {
          await deleteFileFromStorage(imageUrl);
        }
      }

      // Delete associated documents from Firebase Storage
      if (documentURLs != null && documentURLs.isNotEmpty) {
        for (String documentUrl in documentURLs) {
          await deleteFileFromStorage(documentUrl);
        }
      }
    } catch (e) {
      print("Error deleting note or files: $e");
    }
  }
}
