import 'package:flutter/material.dart';
import 'TextAsset.dart';

class CommonSection {
  final String sectionString;

  CommonSection(this.sectionString);

  static Widget getHeader1(String sectionString) {
    return Row(children: [
      Spacer(),
      Text(
        sectionString,
        style: TextAssset.header1,
      ),
      Spacer(),
    ]);
  }

  static Widget getHeader2(context, sectionString) {
    return SizedBox(
        width: double.infinity,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
              child: Text("<"),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          Spacer(),
          Text(
            sectionString,
            style: TextAssset.header2,
          ),
          Spacer(),
          TextButton(
              child: Text(""),
              onPressed: () {
                // Navigator.of(context).pop();
              }),
          // Spacer(),
          // SizedBox()
        ]));
  }

  // static const Footter = TextStyle(
  //   fontSize: 26,
  //   color: Color(0xff131313),
  //   fontStyle: FontStyle.normal,
  //   fontWeight: FontWeight.w700,
  //   fontFamily: 'Inter',
  // );
}
