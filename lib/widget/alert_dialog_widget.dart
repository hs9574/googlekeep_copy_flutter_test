import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {

  String title;
  Function? onClose;
  EdgeInsetsGeometry titlePadding;
  EdgeInsetsGeometry buttonPadding;
  EdgeInsetsGeometry actionsPadding;
  EdgeInsetsGeometry contentPadding;
  Widget content;
  List<Widget> actions;
  Color backgroundColor;

  AlertDialogWidget({
    this.title = '',
    this.onClose,
    this.titlePadding = EdgeInsets.zero,
    this.buttonPadding = EdgeInsets.zero,
    this.actionsPadding = EdgeInsets.zero,
    this.contentPadding = EdgeInsets.zero,
    this.content = const SizedBox(),
    this.actions = const [],
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xff4280D0),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0),
            topRight: Radius.circular(10.0)
          )
        ),
        child: Stack(
            children: [
              Center(child: Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, height: 1))),
              Positioned(
                top: -2,
                right: 10,
                child: InkWell(onHover: null,
                  onTap: () {
                    if(onClose != null){
                      onClose!();
                    }else{
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ]
        ),
      ),
      titlePadding: titlePadding,
      buttonPadding: buttonPadding,
      actionsPadding: actionsPadding,
      contentPadding: contentPadding,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      backgroundColor: backgroundColor,
      content: content,
      actions: actions,
    );
  }
}
