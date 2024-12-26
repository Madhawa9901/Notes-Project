import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes/services/attachments.dart'; // Import your AttachmentHandler class

class NotePage extends StatefulWidget {
  final String? initialTitle;
  final String? initialNote;
  final List<String>? initialImageUrls; // Updated to a list for multiple images
  final List<String>? initialDocumentUrls; // Updated to a list for multiple documents

  const NotePage({super.key, this.initialTitle, this.initialNote, this.initialImageUrls, this.initialDocumentUrls});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final List<File> attachedFiles = []; // To store new files (images and documents)
  final List<String> existingFileUrls = []; // To store existing URLs for files
  final AttachmentHandler attachmentHandler = AttachmentHandler();
  List<String> imageUrls = [];
  List<String> documentUrls = [];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle ?? '';
    noteController.text = widget.initialNote ?? '';
    imageUrls = widget.initialImageUrls ?? [];
    documentUrls = widget.initialDocumentUrls ?? [];

    // Combine existing image and document URLs into a single list for display
    existingFileUrls.addAll(imageUrls);
    existingFileUrls.addAll(documentUrls);
  }

  /// Extract file name from a URL
  String getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'Unknown file';
  }

  void autoSave() async {
    if (titleController.text.isNotEmpty || noteController.text.isNotEmpty) {
      List<String> uploadedImageUrls = List<String>.from(imageUrls);
      List<String> uploadedDocumentUrls = List<String>.from(documentUrls);

      // Separate new files into images and documents
      List<File> imageFiles = [];
      List<File> documentFiles = [];

      for (var file in attachedFiles) {
        if (file.path.endsWith('.pdf') ||
            file.path.endsWith('.doc') ||
            file.path.endsWith('.docx') ||
            file.path.endsWith('.txt')) {
          documentFiles.add(file);
        } else {
          imageFiles.add(file);
        }
      }

      // Batch upload new images
      if (imageFiles.isNotEmpty) {
        try {
          final List<String> imageUploadResults = await attachmentHandler.uploadImages(imageFiles);
          uploadedImageUrls.addAll(imageUploadResults);
        } catch (e) {
          print("Error uploading images: $e");
        }
      }

      // Batch upload new documents
      if (documentFiles.isNotEmpty) {
        try {
          final List<String> documentUploadResults = await attachmentHandler.uploadDocuments(documentFiles);
          uploadedDocumentUrls.addAll(documentUploadResults);
        } catch (e) {
          print("Error uploading documents: $e");
        }
      }

      // Return data to the previous screen
      Navigator.pop(context, {
        'title': titleController.text,
        'note': noteController.text,
        'attachments': uploadedImageUrls,
        'documents': uploadedDocumentUrls,
      });
    } else {
      Navigator.pop(context); // Close the page if no content
    }
  }

  void attachFileOrDocument() async {
    final dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () async {
                Navigator.pop(context, await attachmentHandler.pickImagesFromGallery());
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context, await attachmentHandler.pickImageFromCamera());
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: const Text('Pick a Document'),
              onTap: () async {
                Navigator.pop(context, await attachmentHandler.pickDocuments());
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        if (result is File) {
          attachedFiles.add(result);
        } else if (result is List<File>) {
          attachedFiles.addAll(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        autoSave();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: attachFileOrDocument,
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.avif"),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter title...',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TextField(
                    controller: noteController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: 'Type your note here...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(right: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Display existing and attached files
                Expanded(
                  child: ListView.builder(
                    itemCount: existingFileUrls.length + attachedFiles.length,
                    itemBuilder: (context, index) {
                      if (index < existingFileUrls.length) {
                        final url = existingFileUrls[index];
                        final fileName = getFileNameFromUrl(url);
                        return ListTile(
                          leading: Icon(
                            fileName.endsWith('.pdf') || fileName.endsWith('.doc') || fileName.endsWith('.txt')
                                ? Icons.insert_drive_file
                                : Icons.image,
                            color: Colors.white,
                          ),
                          title: Text(
                            fileName,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                existingFileUrls.removeAt(index);
                              });
                            },
                          ),
                        );
                      } else {
                        final file = attachedFiles[index - existingFileUrls.length];
                        return ListTile(
                          leading: Icon(
                            file.path.endsWith('.pdf') || file.path.endsWith('.docx') || file.path.endsWith('.txt')
                                ? Icons.insert_drive_file
                                : Icons.image,
                            color: Colors.white,
                          ),
                          title: Text(
                            file.path.split('/').last,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                attachedFiles.removeAt(index - existingFileUrls.length);
                              });
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: autoSave,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    super.dispose();
  }
}
