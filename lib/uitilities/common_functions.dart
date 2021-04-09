import 'dart:io';

import 'package:flutter/material.dart' show Color, Colors;

class CommonFunctions {
  static Color bmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.orange;
    } else if (bmi >= 18.5 && bmi < 25) {
      return Colors.green;
    } else if (bmi >= 25 && bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static Color progreesBarColor(double progress) {
    if (progress < 0.25) {
      return Colors.green;
    } else if (progress >= 0.25 && progress < 0.75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static const List<Color> indicatorColors = const [
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.blueGrey,
  ];

  static const List<Color> particleColors = const [
    Colors.green,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.green,
    Colors.orange,
    Colors.purple
  ];

  static Future<List<File>> generateImageList(List<String> imageData,
      {onImageNotFound(String imagePath)}) async {
    List<File> images = [];
    imageData.reversed.forEach((element) async {
      File image = File(element);
      if (await image.exists()) {
        images.add(image);
      } else {
        onImageNotFound(element);
      }
    });
    return images;
  }
}
