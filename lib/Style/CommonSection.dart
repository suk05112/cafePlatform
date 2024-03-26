import 'package:flutter/material.dart';
import './TextAsset.dart';

class CommonSection {
  final String sectionString;

  CommonSection(this.sectionString);

  static Widget getHeader(String sectionString) {
    // Widget getHeader() {
    return Row(children: [
      Spacer(),
      Text(
        sectionString,
        style: TextAssset.header1,
      ),
      Spacer(),
    ]);
  }

  // static const Footter = TextStyle(
  //   fontSize: 26,
  //   color: Color(0xff131313),
  //   fontStyle: FontStyle.normal,
  //   fontWeight: FontWeight.w700,
  //   fontFamily: 'Inter',
  // );
}
