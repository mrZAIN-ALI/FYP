import 'package:cloud_firestore/cloud_firestore.dart';

class FormRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Submit a new form
  Future<void> submitForm(Map<String, dynamic> formData) async {
    try {
      await _firestore.collection('doctor_requests').add(formData);
      print('Form successfully submitted.');
    } catch (e) {
      print('Error submitting form: $e');
      rethrow;
    }
  }

  // Fetch pending requests
  Stream<List<QueryDocumentSnapshot>> getPendingRequests() {
    return _firestore
        .collection('doctor_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Update the status of a request
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('doctor_requests').doc(requestId).update({'status': status});
      print('Request status updated to $status.');
    } catch (e) {
      print('Error updating request status: $e');
      rethrow;
    }
  }
}

final formRepository = FormRepository();
