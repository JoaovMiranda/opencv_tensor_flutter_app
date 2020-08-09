import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraHelper {
  static Future<File> pickImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source);
    if (image == null) {
      return null;
    }
    return image;
  }
}