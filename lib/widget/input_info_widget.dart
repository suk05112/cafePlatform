import 'package:flutter/material.dart';
import 'package:cafeplatform/Style/ColorAsset.dart';

class InputInfoWidget extends StatefulWidget {
  InputInfoWidget(
      {super.key,
      required this.title,
      required this.hintText,
      required this.validator,
      required this.onChanged,
      this.hidePassword});

  final String title;
  String hintText;
  Function(String?) validator;
  final Function(String) onChanged;
  bool? hidePassword;

  @override
  State<InputInfoWidget> createState() => _InputInfoWidgetState();
}

class _InputInfoWidgetState extends State<InputInfoWidget> {
  TextEditingController inputController = TextEditingController();
  bool? _hidePassword;

  @override
  void initState() {
    super.initState();
    if (widget.hidePassword != null) {
      _hidePassword = widget.hidePassword!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          // const SizedBox(height: 8),
          TextFormField(
            controller: inputController,
            obscureText: _hidePassword == null ? false : _hidePassword!,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: ColorAssset.mainColor, width: 2),
              ),
              suffixIcon: _hidePassword == null
                  ? null
                  : IconButton(
                      icon: Icon(
                        _hidePassword!
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword!;
                        });
                      },
                    ),
            ),
            validator: (value) {
              return widget.validator(value);
            },
            onChanged: (value) {
              widget.onChanged(value); // 입력 값 변경 시 콜백 호출
            },
          ),
          const SizedBox(height: 20),
        ]);
  }

  final inputDecoration = InputDecoration(border: UnderlineInputBorder());
}

final inputDecoration = InputDecoration(
  // isDense: true,
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: Colors.redAccent,
        width: 2,
      )),
);
