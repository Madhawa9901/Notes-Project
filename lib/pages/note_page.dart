import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes/services/attachments.dart';  // Import your AttachmentHandler class

class NotePage extends StatefulWidget {
  final String? initialTitle;
  final String? initialNote;

  const NotePage({super.key, this.initialTitle, this.initialNote});

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  File? attachedFile;
  final AttachmentHandler attachmentHandler = AttachmentHandler();
  String? imageUrl;  // Store Firebase download URL

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values
    titleController.text = widget.initialTitle ?? '';
    noteController.text = widget.initialNote ?? '';
  }

  // Auto-save function
  void autoSave() async {
    // Check if either the title or note has content before saving
    if (titleController.text.isNotEmpty || noteController.text.isNotEmpty) {
      String? uploadedImageUrl;

      // If a file is attached, upload it to Firebase
      if (attachedFile != null) {
        uploadedImageUrl = await attachmentHandler.uploadImage(attachedFile!);
      }

      // Pass back the title, note, and image URL even if the user didn't press save
      Navigator.pop(context, {
        'title': titleController.text,
        'note': noteController.text,
        'attachment': uploadedImageUrl  // Pass the uploaded image URL
      });
    } else {
      // If no content, just go back without saving
      Navigator.pop(context);
    }
  }

  // Attach a file (image) from gallery or camera
  void attachFile() async {
    final File? pickedFile = await showModalBottomSheet<File>(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from Gallery'),
                onTap: () async {
                  Navigator.pop(context, await attachmentHandler.pickImageFromGallery());
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context, await attachmentHandler.pickImageFromCamera());
                },
              ),
            ],
          );
        }
    );

    if (pickedFile != null) {
      setState(() {
        attachedFile = pickedFile;  // Set selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        autoSave();  // Trigger auto-save when the back button is pressed
        return false; // Prevent default pop behavior; we handle it
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Note'),
          actions: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: attachFile,  // Attach file when pressed
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.avif"),  // Background image
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Title input field
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

                // Note input field
                Expanded(
                  child: TextField(
                    controller: noteController,
                    maxLines: null,  // Allows multiple lines
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

                // Display attached file preview
                if (attachedFile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                    ),
                    child: Image.file(
                      attachedFile!,
                      fit: BoxFit.cover,
                    ),
                  ),

                // Save button
                ElevatedButton(
                  onPressed: () {
                    // Explicit save when the button is pressed
                    autoSave();
                  },
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
