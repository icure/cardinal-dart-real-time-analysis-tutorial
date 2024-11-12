import 'package:cardinal_real_time_tutorial/cardinal/utils.dart';
import 'package:cardinal_sdk/auth/authentication_method.dart';
import 'package:cardinal_sdk/auth/credentials.dart';
import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/crypto/entities/patient_share_options.dart';
import 'package:cardinal_sdk/crypto/entities/secret_id_share_options.dart';
import 'package:cardinal_sdk/crypto/entities/share_metadata_behaviour.dart';
import 'package:cardinal_sdk/model/patient.dart';
import 'package:cardinal_sdk/model/requests/requested_permission.dart';
import 'package:cardinal_sdk/model/user.dart';
import 'package:cardinal_sdk/options/storage_options.dart';

import 'create_sdk.dart';

Future<User> createPatientSdk(CardinalSdk sdk) async {
  final newPatient = DecryptedPatient(
    generateUuid(),
    firstName: "Edmond",
    lastName: "Dantes",
  );
  final patientWithMetadata = await sdk.patient.withEncryptionMetadata(newPatient);
  final createdPatient = await sdk.patient.createPatient(patientWithMetadata);
  final login = "edmond.dantes.${generateUuid().substring(0, 6)}@icure.com";
  final patientUser = User(
      generateUuid(),
      patientId: createdPatient.id,
      login: login,
      email: login
  );
  final createdUser = await sdk.user.createUser(patientUser);
  final loginToken = await sdk.user.getToken(createdUser.id, "login");

  await CardinalSdk.initialize(
      null,
      cardinalUrl,
      AuthenticationMethod.UsingCredentials(Credentials.UsernamePassword(login, loginToken)),
      StorageOptions.PlatformDefault
  );

  await sdk.patient.shareWith(
      createdPatient.id,
      createdPatient,
      options: PatientShareOptions(
          shareSecretIds: SecretIdShareOptionsAllAvailable(true),
          shareEncryptionKey: ShareMetadataBehaviour.ifAvailable,
          requestedPermissions: RequestedPermission.maxWrite
      )
  );

  await createSdk(login, loginToken);

  return createdUser;
}