import 'dart:io';

class DriverDocumentModel {
  final String key;
  final String? document_id;
  final String? expire_date;
  final File? document;

  DriverDocumentModel({
    required this.key,
    this.document_id,
    this.expire_date,
    this.document,
  });

  Map<String, dynamic> toJson() {
    return {
      'document_id': document_id,
      'expire_date': expire_date,
      'document_path': document?.path, // File paths are used instead of the File object itself
    };
  }
}
