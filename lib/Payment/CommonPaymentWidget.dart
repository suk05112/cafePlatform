import 'package:flutter/material.dart';
import 'package:cafeplatform/model/menu.dart';
import 'package:cafeplatform/provider/menu_provider.dart';
import 'package:provider/provider.dart';

class CommonPaymentWidget {
  static Widget getGiftInfo() {
    return Consumer<MenuProvider>(builder: (context, menuProvider, child) {
      Menu menu = menuProvider.getSelectedMenu();
      final hasImage =
          menu.menu_image_url != null && menu.menu_image_url!.trim().isNotEmpty;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 정방형 이미지 (이미지가 있을 경우만 표시)
            if (hasImage) ...[
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.4, // 카드 너비의 40%만 사용해서 크기 축소
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 1, // 정방형
                      child: Image.network(
                        menu.menu_image_url!.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // 이름
            Text(
              menu.name ?? "",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            // 가격
            Text(
              "${menu.price}원",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            // 설명
            if (menu.description != "")
              Text(
                menu.description ?? "",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
          ],
        ),
      );
    });
  }

/*
  Widget goToPay() {
    return Center(
        // Elevated Button 위젯
        child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
        ),
        child: Text('4500원 결제하기'),

        // 클릭 이벤트
        onPressed: () {
          // setState() 메서드를 수행시 다시 build() 메서드가 실행되며 동적 화면이 구현된다.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Payment()),
            );
          );
        },
      ),
    ));
  }
  }
  */
}

class InputInfoWidget extends StatefulWidget {
  InputInfoWidget(
      {super.key,
      required this.title,
      required this.hintText,
      required this.validator,
      required this.onChange});

  final String title;
  String hintText;
  Function(String?) validator;
  Function(String?) onChange;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10.0),
          Text(widget.title),
          TextFormField(
            controller: inputController,
            keyboardType: TextInputType.text,
            decoration: inputDecoration.copyWith(hintText: widget.hintText),
            validator: (value) {
              return widget.validator(value);
            },
            onChanged: (value) => widget.onChange(value), // onChange 이벤트 호출
          ),
        ]);
  }

  final inputDecoration = InputDecoration(
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          )));
}

void showModalDialog(BuildContext context, String message) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Text("dialog");
        // return LoplatDialogCenterConfirm(
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Expanded(
        //           child : Padding(
        //             padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
        //             child: Center(
        //               child: Text(message, textAlign: TextAlign.center,
        //               style: const TextStyle(
        //                   color: Colors.black,
        //                   fontSize: 18,
        //                   fontFamily: 'AppleSDGothicNeo',
        //                     fontWeight: FontWeight.w700,
        //                 ),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        //   confirmLabel: '확인',
        // );
      });
}
