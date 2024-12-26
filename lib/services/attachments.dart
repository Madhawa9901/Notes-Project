import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AttachmentHandler {
  final ImagePicker _picker = ImagePicker();

  // Pick multiple images from the gallery
  Future<List<File>> pickImagesFromGallery() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      return pickedFiles.map((file) => File(file.path)).toList();
    }
    return [];
  }

  // Pick a single image from the camera
  Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> downloadUrls = [];
    for (var imageFile in imageFiles) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${DateTime.now().toString()}.jpg');
        UploadTask uploadTask = storageRef.putFile(imageFile);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadURL);
        print("Image uploaded successfully: $downloadURL");
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return downloadUrls;
  }

  // Pick multiple documents
  Future<List<File>> pickDocuments() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'], // Allowed document types
      allowMultiple: true, // Allow multiple files to be selected
    );
    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    }
    return [];
  }

  // Upload multiple documents
  Future<List<String>> uploadDocuments(List<File> files) async {
    List<String> downloadUrls = [];
    for (var file in files) {
      try {
        String fileExtension = file.path.split('.').last;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${DateTime.now().toString()}.$fileExtension');
        UploadTask uploadTask = storageRef.putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();
        downloadUrls.add(downloadURL);
        print("Document uploaded successfully: $downloadURL");
      } catch (e) {
        print("Error uploading document: $e");
      }
    }
    return downloadUrls;
  }
}