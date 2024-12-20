import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService{

  //get data
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  final CollectionReference titles = FirebaseFirestore.instance.collection('title');

  //create
  Future<void> addNote(String note, String title, {String? imageURL, String? documentURL}){
    return notes.add({
      'title': title,
      'note': note,
      'imageURL': imageURL ?? '',
      'documentURL': documentURL ?? '',  // Store document URL
      'timestamp': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream = notes.orderBy('timestamp',descending: true).snapshots();
    return notesStream;
  }

  //update
  Future<void> updateNote(String docID, String newNote, String newTitle, {String? imageURL, String? documentURL}) {
    return notes.doc(docID).update({
      'note': newNote,
      'title': newTitle,
      'imageURL': imageURL ?? '',
      'documentURL': documentURL ?? '',  // Store document URL
      'timeStamp': Timestamp.now(),
    });
  }

  //delete
  Future<void> deleteNote(String docID, {String? imageUrl, String? documentUrl}) async {
    try {
      notes.doc(docID).delete();
      print("Note deleted successfully");
      // Delete the image or document from Firebase Storage
      if (imageUrl != null) {
        // Delete the image if the URL is provided
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        print("Image deleted from storage");
      }
      if (documentUrl != null) {
        // Delete the document if the URL is provided
        await FirebaseStorage.instance.refFromURL(documentUrl).delete();
        print("Document deleted from storage");
      }
    } catch (e) {
      print("Error deleting note or file: $e");
    }
  }

  // Future<void> deleteNote(String docID) {
  //   return notes.doc(docID).delete();
  // }

}