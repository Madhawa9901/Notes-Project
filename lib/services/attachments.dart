import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AttachmentHandler {
  final ImagePicker _picker = ImagePicker();

  // Pick image from the gallery
  Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Pick image from the camera
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  //upload image
  Future<String?> uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().toString()}.jpg');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      print("Image uploaded successfully: $downloadURL"); // Debug print
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
    }
    return null;
  }

  // Method to pick a document
  Future<File?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],  // Allowed document types
    );
    return result != null ? File(result.files.single.path!) : null;
  }

  // Method to upload document
  // Method to upload a document
  Future<String?> uploadDocument(File file) async {
    try {
      // Get file extension to properly label the file in storage
      String fileExtension = file.path.split('.').last;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('uploads/${DateTime.now().toString()}.$fileExtension');
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      print("Document uploaded successfully: $downloadURL"); // Debug print
      return downloadURL;
    } catch (e) {
      print("Error uploading document: $e");
    }
    return null;
  }


}
