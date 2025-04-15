import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final formControllerProvider = Provider<FormController>((ref) {
  return FormController();
});

class FormController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> submitForm({
    required String fullName,
    required String fatherName,
    required String registrationNumber,
    required String registrationType,
    required String issueDate,
    required String expiryDate,
    required PlatformFile degreeFile,
    required String uid, // ✅ Include uid for tracking
  }) async {
    try {
      // 1. Upload degree image to Firebase Storage
      final filePath = 'doctor_degrees/${DateTime.now().millisecondsSinceEpoch}_${degreeFile.name}';
      final ref = _storage.ref().child(filePath);
      final uploadTask = await ref.putFile(File(degreeFile.path!));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 2. Prepare data with the image URL and user UID
      final formData = {
        'fullName': fullName,
        'fatherName': fatherName,
        'registrationNumber': registrationNumber,
        'registrationType': registrationType,
        'issueDate': issueDate,
        'expiryDate': expiryDate,
        'degreeFileName': degreeFile.name,
        'degreeFileUrl': downloadUrl,
        'status': 'pending', // pending | approved | rejected
        'submittedAt': FieldValue.serverTimestamp(),
        'uid': uid, // ✅ Store the UID of the doctor
      };

      // 3. Save to Firestore
      await _firestore.collection('doctor_requests').add(formData);
      print('✅ Doctor verification request submitted.');
    } catch (e) {
      print('❌ Error submitting doctor request: $e');
      rethrow;
    }
  }
}
