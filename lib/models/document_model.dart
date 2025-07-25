import 'dart:io';

class Document {
  final String? idNumber;
  final String? expireDate;
  final File? file;
  final String? fileType;

  Document({
    this.idNumber,
    this.expireDate,
    this.file,
    this.fileType,
  });
}