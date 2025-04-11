import 'package:flutter/material.dart';

class FruitModel {
  String image;
  Color color;
  bool isBomb;

  FruitModel({
    required this.image,
    this.color = Colors.transparent,
    this.isBomb = false,
  });
}
