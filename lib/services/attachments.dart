import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
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
    try{
      final storeageRef = FirebaseStorage.instance.ref().child('uploads/${DateTime.now().toString()}.jpg');
      UploadTask uploadTask = storeageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    }catch(e){
      print("Error uploading image: $e");
    }
    return null;
  }

}