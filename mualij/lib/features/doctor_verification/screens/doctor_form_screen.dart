import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/form_controller.dart';

class DoctorFormScreen extends ConsumerStatefulWidget {
  @override
  _DoctorFormScreenState createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends ConsumerState<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();
  String? _registrationType;
  PlatformFile? _degreeFile;

  bool _isLoading = true;
  bool _canSubmit = true;
  String? _statusMessage;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) {
      _checkPreviousRequest();
    } else {
      setState(() {
        _isLoading = false;
        _canSubmit = false;
        _statusMessage = "You must be logged in to submit a request.";
      });
    }
  }

  Future<void> _checkPreviousRequest() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctor_requests')
        .where('uid', isEqualTo: _uid)
        .orderBy('submittedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      final status = data['status'];
      final remarks = data['remarks'];

      if (status == 'pending') {
        _statusMessage = '🕓 Your verification request is pending.\nPlease wait for admin review.';
        _canSubmit = false;
      } else if (status == 'approved') {
        _statusMessage = '✅ You are already a verified doctor.';
        _canSubmit = false;
      } else if (status == 'rejected') {
        _statusMessage = '❌ Your previous request was rejected.\n\n📝 Admin Remarks:\n$remarks\n\nYou may try again.';
        _canSubmit = true;
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_degreeFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please attach your degree image.")),
        );
        return;
      }

      ref.read(formControllerProvider).submitForm(
        fullName: _fullNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim(),
        registrationType: _registrationType!,
        issueDate: _issueDateController.text,
        expiryDate: _expiryDateController.text,
        degreeFile: _degreeFile!,
        uid: _uid!,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Success"),
          content: Text("Your verification request has been submitted."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        ),
      );

      _formKey.currentState?.reset();
      setState(() => _degreeFile = null);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validationPattern,
    required String errorMessage,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty || !RegExp(validationPattern).hasMatch(value.trim())) {
          return errorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildDateField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(controller),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Select $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    const fieldSpacing = SizedBox(height: 16);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Doctor Verification")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Doctor Verification")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_statusMessage != null && _statusMessage!.contains('rejected'))
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_canSubmit)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      validationPattern: r'^[a-zA-Z\s]+$',
                      errorMessage: 'Enter a valid name',
                    ),
                    fieldSpacing,
                    _buildTextField(
                      controller: _fatherNameController,
                      label: 'Father Name',
                      validationPattern: r'^[a-zA-Z\s]+$',
                      errorMessage: 'Enter a valid father name',
                    ),
                    fieldSpacing,
                    _buildTextField(
                      controller: _registrationNumberController,
                      label: 'Registration Number',
                      validationPattern: r'.+',
                      errorMessage: 'Required field',
                    ),
                    fieldSpacing,
                    DropdownButtonFormField<String>(
                      value: _registrationType,
                      decoration: InputDecoration(
                        labelText: 'Registration Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Permanent', 'Temporary']
                          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) => setState(() => _registrationType = val),
                      validator: (val) => val == null ? 'Please select registration type' : null,
                    ),
                    fieldSpacing,
                    _buildDateField(_issueDateController, 'Issue Date'),
                    fieldSpacing,
                    _buildDateField(_expiryDateController, 'Expiry Date'),
                    fieldSpacing,
                    ElevatedButton.icon(
                      icon: Icon(Icons.file_upload),
                      label: Text(_degreeFile == null ? "Attach Degree Image" : _degreeFile!.name),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                        if (result != null) setState(() => _degreeFile = result.files.first);
                      },
                    ),
                    fieldSpacing,
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        child: Text("Submit Verification Request"),
                      ),
                    ),
                  ],
                ),
              ),
            if (!_canSubmit && (_statusMessage != null && !_statusMessage!.contains('rejected')))
              Center(
                child: Text(
                  _statusMessage ?? "You cannot submit a request at this time.",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
