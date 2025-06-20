import 'package:json_annotation/json_annotation.dart';
import 'package:dynamicemrapp/model/scan_document_dto.dart';
// -- scan_document_master_dto.dart --

part 'scan_document_master_dto.g.dart';

@JsonSerializable()
class ScanDocumentMasterDto {
  List<ScanDocumentDto>? uploadFiles;
  String? source;
  String? pictureSource;
  String? isScanCompleted;
  String? pictureType;

  ScanDocumentMasterDto(
    this.uploadFiles,
    this.source,
    this.pictureSource,
    this.isScanCompleted,
    this.pictureType,
  );

  factory ScanDocumentMasterDto.fromJson(Map<String, dynamic> json) =>
      _$ScanDocumentMasterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ScanDocumentMasterDtoToJson(this);
}
