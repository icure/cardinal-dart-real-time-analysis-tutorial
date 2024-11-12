import 'package:cardinal_sdk/cardinal_sdk.dart';
import 'package:cardinal_sdk/filters/service_filters.dart';
import 'package:collection/collection.dart';

Future<List<String>> retrieveDiagnoses(CardinalSdk patientSdk) async {
  final filter = await ServiceFilters.byTagAndValueDateForSelf(
      "CARDINAL",
      tagCode: "ANALYZED"
  );
  final serviceIterator = await patientSdk.contact.filterServicesBy(filter);

  List<String> diagnoses = [];
  while(await serviceIterator.hasNext()) {
    final service = (await serviceIterator.next(1)).first;
    final diagnosisOrNull = service.tags.firstWhereOrNull((tag) => tag.type == "SNOMED");
    if (diagnosisOrNull != null) {
      final code = await patientSdk.code.getCode(diagnosisOrNull.id!);
      diagnoses.add("The diagnosis for sample ${service.id} is ${code.label?["en"]}");
    }
  }
  return diagnoses;
}