import 'package:cloud_firestore/cloud_firestore.dart';

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
    );
  }
}
