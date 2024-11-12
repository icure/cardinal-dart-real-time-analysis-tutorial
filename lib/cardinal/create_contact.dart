import 'dart:math';

import 'package:cardinal_real_time_tutorial/cardinal/utils.dart';
import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/model/base/code_stub.dart';
import 'package:cardinal_sdk/model/contact.dart';
import 'package:cardinal_sdk/model/embed/access_level.dart';
import 'package:cardinal_sdk/model/embed/content.dart';
import 'package:cardinal_sdk/model/embed/measure.dart';
import 'package:cardinal_sdk/model/embed/service.dart';
import 'package:cardinal_sdk/model/patient.dart';

Future<DecryptedContact> createContact(CardinalSdk patientSdk, DecryptedPatient patient) async {
  final glycemiaValue = (100 + Random().nextInt(60)).toDouble();
  final contact = DecryptedContact(
      generateUuid(),
      openingDate: currentDateAsYYYYMMddHHmmSS(),
      services: {
        DecryptedService(
          generateUuid(),
          content: {
            "en": DecryptedContent(
              measureValue: Measure(
                value: glycemiaValue,
                unitCodes: {
                  CodeStub(
                      id: "UCUM|mmol/L|1",
                      type: "UCUM",
                      code: "mmol/L",
                      version: "1"
                  )
                }
            )
          )
        },
        tags: {
          CodeStub(
              id: "LOINC|2339-0|1",
              type: "LOINC",
              code: "2339-0",
              version: "1"
          ),
          CodeStub(
              id: "CARDINAL|TO_BE_ANALYZED|1",
              type: "CARDINAL",
              code: "TO_BE_ANALYZED",
              version: "1"
          )
      }
    )}
  );

  final recipientHcp = patient.responsible;
  if (recipientHcp == null) {
    throw ArgumentError("Patient has no responsible");
  }
  final contactWithEncryptionMetadata = await patientSdk.contact.withEncryptionMetadata(
    contact,
    patient,
    delegates: { recipientHcp: AccessLevel.write }
  );
  return patientSdk.contact.createContact(contactWithEncryptionMetadata);
}