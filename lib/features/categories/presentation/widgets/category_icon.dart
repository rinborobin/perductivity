import 'package:flutter/material.dart';

const _categoryIcons = <int, IconData>{
  0xe3a9: IconData(0xe3a9, fontFamily: 'MaterialIcons'),
  0xe866: IconData(0xe866, fontFamily: 'MaterialIcons'),
  0xe896: IconData(0xe896, fontFamily: 'MaterialIcons'),
  0xe0b0: IconData(0xe0b0, fontFamily: 'MaterialIcons'),
  0xe559: IconData(0xe559, fontFamily: 'MaterialIcons'),
  0xe8b8: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
  0xe8f1: IconData(0xe8f1, fontFamily: 'MaterialIcons'),
  0xe87c: IconData(0xe87c, fontFamily: 'MaterialIcons'),
};

const _defaultCategoryIcon = IconData(0xe3a9, fontFamily: 'MaterialIcons');

IconData categoryIconFromString(String value) {
  return _categoryIcons[int.tryParse(value)] ?? _defaultCategoryIcon;
}
