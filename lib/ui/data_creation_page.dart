import 'package:cardinal_sdk/model/health_element.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../cardinal/create_contact.dart';
import '../cardinal/create_patient.dart';
import '../cardinal/create_sdk.dart';
import '../cardinal/retrieve_diagnosis.dart';


class DataCreationPage extends StatefulWidget {
  const DataCreationPage({super.key});

  @override
  _DataCreationPageState createState() => _DataCreationPageState();
}

class _DataCreationPageState extends State<DataCreationPage> {

  int _stage = 1;
  DecryptedHealthElement? currentHealthElement;
  bool? shareStatus;
  String? output;
  late String patientUsername;
  late DecryptedPatient patient;
  bool _isLoading = false;
  bool successfulCreation = true;

  Future<void> _createPatientUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final sdk = sdkCache[mainUsername]!;
      final patientUser = await createPatientSdk(sdk);
      patientUsername = patientUser.login!;
      final patientSdk = sdkCache[patientUsername]!;
      patient = await patientSdk.patient.getPatient(patientUser.patientId!);
      successfulCreation = true;
    } catch(e) {
      successfulCreation = false;
    }
    setState(() {
      _isLoading = false;
      _stage = successfulCreation ? 2 : 1;
    });
  }

  Future<void> _createContactWithPatient() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[patientUsername]!;
    final contact = await createContact(sdk, patient);
    output = "Created contact ${contact.id}";
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _retrieveDiagnoses() async {
    setState(() {
      _isLoading = true;
    });
    final sdk = sdkCache[patientUsername]!;
    final diagnoses = await retrieveDiagnoses(sdk);
    output = "Diagnoses:\n${diagnoses.join('\n')}";
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a contact with a patient and then retrieve'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_stage == 1) ...[
              Text(!successfulCreation ? "There was an error creating the patient" : ""),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createPatientUser,
                child: const Text('Create Patient User'),
              ),
            ] else if (_stage == 2) ...[
              const Text("Choose an operation"),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createContactWithPatient,
                child: const Text('Create a Contact'),
              ),
              _isLoading
                  ? const SizedBox(height: 20)
                  : ElevatedButton(
                onPressed: _retrieveDiagnoses,
                child: const Text('Retrieve analysis result'),
              )
            ],
            const SizedBox(height: 20),
            Text(output != null ? output! : "")
          ],
        ),
      ),
    );
  }
}
