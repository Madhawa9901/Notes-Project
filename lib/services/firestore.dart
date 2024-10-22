import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService{

  //get data
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  final CollectionReference titles = FirebaseFirestore.instance.collection('title');

  //create
  Future<void> addNote(String note, String title, {String? imageURL}){
    return notes.add({
      'title': title,
      'note': note,
      'imageURL': imageURL ?? '',
      'timestamp': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getNotesStream() {
    final notesStream = notes.orderBy('timestamp',descending: true).snapshots();

    return notesStream;
  }

  //update
  Future<void> updateNote(String docID, String newNote, String newTitle, {String? imageURL}) {
    return notes.doc(docID).update({
      'note': newNote,
      'title': newTitle,
      'imageURL': imageURL ?? '',
      'timeStamp': Timestamp.now(),
    });
  }

  //delete
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }

}