import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class Payment_Terms extends StatelessWidget {
  const Payment_Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('결제서비스를 위한 개인(신용)정보 제공 동의'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          // 수직 스크롤 지원
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 20, 10, 0),
            child: FutureBuilder(
              future: loadAsset(
                  'assets/terms/Agree to provision of personal (credit) information for payment service.txt'),
              builder: (context, snapshot) {
                // snapshot은 Future 클래스가 포장하고 있는 객체를 data 속성으로 전달                        // Future<String>이기 때문에 data는 String이 된다.
                final contents = snapshot.data.toString();
                // 개행 단위로 분리
                // final rows = contents.split('\n');
                // var tableRows = <TableRow>[];
                // for (var row in rows) {
                //   // 이번 파일에서 구분 문자는 콜론(:)
                //   var cols = row.split(':');
                //   // 마지막 줄은 빈 줄이라서 컬럼 개수가 3개가 아니다.
                //   if (cols.length != 3)
                //     continue; // map 함수를 이용해서 문자열 각각에 대해 Text 위젯 생성
                //   var widgets = cols.map((s) => Text(s));
                //   tableRows.add(TableRow(children: widgets.toList()));
                // }
                // return Table(children: tableRows);
                return Text(contents);
              },
            ),
          ),
        ));
  }
  // assets 폴더 아래에 2016_GDP.txt 파일 있어야 함.
  // AssetBundle 객체를 통해 리소스에 접근.
  // // DefaultAssetBundle 클래스 또는 미리 만들어 놓은 rootBundle 객체 사용.
  // async는 비동기 함수, await는 비동기 작업이 종료될 때까지 기다린다는 뜻.
  //  그러나, 함수 자체가 블록되지는 않고 예약 전달의 형태로 함수 반환됨.
  // 따라서 Future 클래스를 사용하기 위해서는 FutureBuilder 등의 특별한 클래스가 필요함.

  Future<String> loadAsset(String path) async {
    return await rootBundle.loadString(path);
    // return await DefaultAssetBundle.of(ctx).loadString('assets/2016_GDP.txt');
  }
}
