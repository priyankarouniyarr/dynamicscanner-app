import 'package:json_annotation/json_annotation.dart';
// -- patient_for_scanner_client_view_model.dart --

part 'patient_for_scanner_client_view_model.g.dart';

@JsonSerializable()
class PatientForScannerClientViewModel {
  int id;

  String firstName;
  String? middleName;
  String lastName;
  String fullName;
  String? dateOfBirth;
  String? gender;
  List<dynamic> visits;

  PatientForScannerClientViewModel(
    this.id,

    this.firstName,
    this.middleName,
    this.lastName,
    this.fullName,
    this.dateOfBirth,

    this.gender,
    this.visits,
  );

  factory PatientForScannerClientViewModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PatientForScannerClientViewModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PatientForScannerClientViewModelToJson(this);
}
