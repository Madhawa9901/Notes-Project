import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/pages/note_page.dart';
import 'package:notes/pages/note_view_page.dart';
import '../services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the NotePage and wait for the note text to be returned
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotePage(),
            ),
          );
          // If the user returns with a note, ensure result is a valid Map and contains title and note
          if (result != null && result is Map<String, dynamic>) {
            String? title = result['title'];
            String? note = result['note'];
            String? attachment = result['attachment'];
            String? document = result['document'];
            firestoreService.addNote(note!, title!, imageURL: attachment, documentURL: document);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.avif'),
            fit: BoxFit.fill,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            // If there's an error, show the error message
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            // If data is being fetched, show a loading spinner
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if data is available
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              List<DocumentSnapshot> noteList = snapshot.data!.docs;

              // Displaying notes (only the title part)
              return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (context, index) {
                  // Get individual document
                  DocumentSnapshot document = noteList[index];
                  String docID = document.id;

                  // Get note from document, ensure null safety for 'title'
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  String noteTitle = data['title'] ?? 'Untitled';
                  String? documentURL = data['documentURL'];

                  // Display as ListTile with a semi-transparent background
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3), // Semi-transparent background
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteViewPage(
                              title: noteTitle,
                              note: data['note'],
                              imageUrl: data['imageURL'],
                              documentUrl: documentURL,  // Pass document URL to NoteViewPage
                            ),
                          ),
                        );
                      },
                      title: Text(
                        noteTitle,
                        style: const TextStyle(
                          color: Colors.white, // White text for visibility
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Update
                          IconButton(
                            onPressed: () async {
                              // Navigate to NotePage and pass existing title, note, and image URL
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotePage(
                                    initialTitle: noteTitle,  // Pass the existing title
                                    initialNote: data['note'], // Pass the existing note
                                    initialImageUrl: data['imageURL'], // Pass the existing image URL
                                    initialDocumentUrl: documentURL,  // Pass initial document URL
                                  ),
                                ),
                              );
                              // If the user returns with a note, update Firestore
                              if (result != null && result is Map<String, dynamic>) {
                                String? updatedTitle = result['title'];
                                String? updatedNote = result['note'];
                                String? updatedAttachment = result['attachment'];
                                String? updatedDocument = result['document'];
                                firestoreService.updateNote(docID, updatedNote!, updatedTitle!, imageURL: updatedAttachment, documentURL: updatedDocument);
                              }
                            },
                            icon: const Icon(Icons.update, color: Colors.white),
                          ),

                          // Delete button
                          IconButton(
                            onPressed: () {
                              firestoreService.deleteNote(
                                docID,
                                imageUrl: data['imageURL'],
                                documentUrl: documentURL,
                              );
                            },
                            icon: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No Notes....', style: TextStyle(color: Colors.white)));
            }
          },
        ),
      ),
    );
  }
}