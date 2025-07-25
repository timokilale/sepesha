import 'dart:io';

class Vehicle {
  final String? year;
  final String? manufacturer;
  final String? model;
  final String? color;
  final String? plateNumber;
  final File? frontImage;
  final File? backImage;
  Vehicle({
    this.year,
    this.manufacturer,
    this.model,
    this.color,
    this.plateNumber,
    this.frontImage,
    this.backImage,

  });
}