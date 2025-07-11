part of 'credential_model.dart';

CredentialModel _$CredentialModelFromJson(Map<String, dynamic> json) =>
    CredentialModel(
      json['username'] as String,
      json['password'] as String,
      json['branchId'] as int,
    );

Map<String, dynamic> _$CredentialModelToJson(CredentialModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'branchId': instance.branchId,
    };
