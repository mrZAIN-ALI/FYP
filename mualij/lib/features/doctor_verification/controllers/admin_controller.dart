import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final adminControllerProvider = Provider<AdminController>((ref) {
  return AdminController();
});

final pendingRequestsProvider = StreamProvider.autoDispose<List<Request>>((ref) {
  return ref.read(adminControllerProvider).getPendingRequests();
});

class AdminController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all pending doctor requests
  Stream<List<Request>> getPendingRequests() {
    return _firestore
        .collection('doctor_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Request.fromDocument(doc)).toList());
  }

  // Approve a request and update user's isVerifiedDoctor flag
  Future<void> approveRequest(String requestId, String remarks) async {
    try {
      final docRef = _firestore.collection('doctor_requests').doc(requestId);
      final docSnap = await docRef.get();
      final requestData = docSnap.data() as Map<String, dynamic>;

      await docRef.update({
        'status': 'approved',
        'remarks': remarks,
      });

      if (requestData.containsKey('uid')) {
        final uid = requestData['uid'];
        await _firestore.collection('users').doc(uid).update({
          'isVerifiedDoctor': true,
        });
      }

      print('Request approved and user marked as verified.');
    } catch (e) {
      print('Error approving request: $e');
      rethrow;
    }
  }

  // Reject a request with remarks (remarks must be passed)
  Future<void> rejectRequest(String requestId, String remarks) async {
    try {
      await _firestore.collection('doctor_requests').doc(requestId).update({
        'status': 'rejected',
        'remarks': remarks,
      });
      print('Request rejected with remarks.');
    } catch (e) {
      print('Error rejecting request: $e');
      rethrow;
    }
  }
}

// Model class for a doctor request
class Request {
  final String id;
  final String fullName;
  final String fatherName;
  final String registrationNumber;
  final String registrationType;
  final String issueDate;
  final String expiryDate;
  final String degreeFileName;
  final String degreeFileUrl;
  final String status;
  String? remarks; // Mutable field for UI editing

  Request({
    required this.id,
    required this.fullName,
    required this.fatherName,
    required this.registrationNumber,
    required this.registrationType,
    required this.issueDate,
    required this.expiryDate,
    required this.degreeFileName,
    required this.degreeFileUrl,
    required this.status,
    this.remarks,
  });

  factory Request.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Request(
      id: doc.id,
      fullName: data['fullName'] ?? '',
      fatherName: data['fatherName'] ?? '',
      registrationNumber: data['registrationNumber'] ?? '',
      registrationType: data['registrationType'] ?? '',
      issueDate: data['issueDate'] ?? '',
      expiryDate: data['expiryDate'] ?? '',
      degreeFileName: data['degreeFileName'] ?? '',
      degreeFileUrl: data['degreeFileUrl'] ?? '',
      status: data['status'] ?? 'pending',
      remarks: data['remarks'],
    );
  }
}
