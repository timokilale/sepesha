import 'package:flutter/material.dart';

class RideOption {
  final String? name;
  final String? price;
  final IconData? icon;
  final String? description;
  final Color? color;
  final String? vehicleType;

  RideOption(
    this.name,
    this.price,
    this.icon,
    this.description,
    this.color,
    this.vehicleType,
  );
}