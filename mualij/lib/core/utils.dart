import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showSnackBar(BuildContext context, String text) {
  try {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  } catch (e) {
    print(e);
  }
}

// Future<FilePickerResult?> pickImage() async {
//   final image = await FilePicker.platform.pickFiles(type: FileType.image);

//   return image;
// }

Future<XFile?> pickImage() async {
  try {
    print("Inside pickImage");
    final ImagePicker picker = ImagePicker();

    // Pick image from gallery
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery, // Can use ImageSource.camera for camera
      maxWidth: 1920, // Optional: Resize image
      maxHeight: 1080, // Optional: Resize image
      imageQuality:
          85, // Optional: Compress image (1-100, higher is better quality)
    );

    if (image != null) {
      print("Image selected: ${image.path}");
      return image;
    } else {
      print("No image selected");
      return null;
    }
  } catch (e, stacktrace) {
    print("Error occurred: $e");
    print("Stacktrace: $stacktrace");
    return null;
  }
}
