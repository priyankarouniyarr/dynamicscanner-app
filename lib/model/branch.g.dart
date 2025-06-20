part of 'branch.dart';

Branch _$BranchFromJson(Map<String, dynamic> json) =>
    Branch(json['id'] as int, json['branchName'] as String);

Map<String, dynamic> _$BranchToJson(Branch instance) => <String, dynamic>{
  'id': instance.id,
  'branchName': instance.branchName,
};
