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
  // Firestore service instance
  final FirestoreService firestoreService = FirestoreService();

  void _showAppInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'About This App',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'This app helps you to create and store private notes. This is a flutter base app and using firebase backend. Thank you for using our app!',
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Notes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white,),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
        IconButton(
        icon: const Icon(Icons.info_outline, color: Colors.white,),
        onPressed: () {
          _showAppInfo(context);
        },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Center(
                  child: Text("About", style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to the NotePage and wait for the note data to be returned
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotePage(),
            ),
          );

          // If the user returns with a note, add it to Firestore
          if (result != null && result is Map<String, dynamic>) {
            String? title = result['title'];
            String? note = result['note'];
            List<String>? attachments = result['attachments'];
            List<String>? documents = result['documents'];
            firestoreService.addNote(note!, title!,
                imageURLs: attachments, documentURLs: documents);
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

              // Displaying notes
              return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = noteList[index];
                  String docID = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteTitle = data['title'] ?? 'Untitled';
                  String noteContent = data['note'] ?? '';
                  List<String>? imageURLs =
                      (data['imageURLs'] as List<dynamic>?)?.cast<String>();
                  List<String>? documentURLs =
                      (data['documentURLs'] as List<dynamic>?)?.cast<String>();

                  // Display as ListTile
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteViewPage(
                              title: noteTitle,
                              note: noteContent,
                              imageUrls: imageURLs,
                              documentUrls: documentURLs,
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
                          // Update button
                          IconButton(
                            onPressed: () async {
                              // Navigate to NotePage with existing data
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotePage(
                                    initialTitle: noteTitle,
                                    initialNote: noteContent,
                                    initialImageUrls: imageURLs,
                                    initialDocumentUrls: documentURLs,
                                  ),
                                ),
                              );

                              // If user returns with updated data, update Firestore
                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                String? updatedTitle = result['title'];
                                String? updatedNote = result['note'];
                                List<String>? updatedAttachments =
                                    result['attachments'];
                                List<String>? updatedDocuments =
                                    result['documents'];
                                firestoreService.updateNote(
                                  docID,
                                  updatedNote!,
                                  updatedTitle!,
                                  imageURLs: updatedAttachments,
                                  documentURLs: updatedDocuments,
                                );
                              }
                            },
                            icon: const Icon(Icons.update, color: Colors.white),
                          ),

                          // Delete button
                          IconButton(
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete File'),
                                    content: const Text(
                                        'Are you sure you want to delete this file?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete == true) {
                                // Perform the delete operation
                                try {
                                  await firestoreService.deleteNote(
                                    docID,
                                    imageURLs: imageURLs,
                                    documentURLs: documentURLs,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('File deleted successfully')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error deleting file: $e')),
                                  );
                                }
                              }
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
              return const Center(
                child: Text(
                  'No Notes....',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
