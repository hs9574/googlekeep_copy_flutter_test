import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldWidget extends StatefulWidget {
  TextEditingController controller;
  String? hintText;
  Function(String)? onSubmitted;
  Function(String)? onChanged;
  Function()? onTap;
  TextStyle? textStyle;
  bool readOnly;
  bool showBorder;

  TextFieldWidget({
    Key? key,
    required this.controller,
    this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.onTap,
    this.textStyle,
    this.readOnly = false,
    this.showBorder = false,
  }) : super(key: key);

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.textStyle,
        border: widget.showBorder ? const OutlineInputBorder() : InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.all(13),
      ),
      keyboardType: TextInputType.multiline,
      readOnly: widget.readOnly,
      maxLines: null,
      style: widget.textStyle,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
    );
  }
}
