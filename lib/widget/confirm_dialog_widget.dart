import 'package:flutter/material.dart';
import 'package:fastapi_project/utils/util.dart';

class ConfirmDialogWidget extends StatefulWidget {
  String text;
  Function? applyOnTap;
  Function? cancelOnTap;

  ConfirmDialogWidget({
    required this.text,
    this.applyOnTap,
    this.cancelOnTap,
  });

  @override
  _ConfirmDialogWidgetState createState() => _ConfirmDialogWidgetState();
}

class _ConfirmDialogWidgetState extends State<ConfirmDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(widget.text),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only(bottom: 4),
      actions: [
        if(widget.applyOnTap != null) TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(8)),
            backgroundColor: MaterialStateProperty.all(DEFAULT_BUTTON_COLOR),
          ),
          onPressed: (){
            widget.applyOnTap!();
          },
            child: Text('확인', style: TextStyle(color: Colors.white, fontSize: 12))),
        if(widget.cancelOnTap != null) TextButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.all(8)),
            backgroundColor: MaterialStateProperty.all(Colors.grey),
          ),
          onPressed: (){
            widget.cancelOnTap!();
          },
          child: Text('취소', style: TextStyle(color: Colors.white, fontSize: 12))),
      ],
    );
  }
}
