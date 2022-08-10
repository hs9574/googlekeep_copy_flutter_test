import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fastapi_project/utils/util.dart';

class DateTextFieldWidget extends StatefulWidget {
  TextEditingController controller;
  String? labelText;
  Function? onChanged;

  static bool pressDeleteKey = false;

  DateTextFieldWidget({
    required this.controller,
    this.labelText,
    this.onChanged,
  });

  @override
  State<DateTextFieldWidget> createState() => _DateTextFieldWidgetState();
}

class _DateTextFieldWidgetState extends State<DateTextFieldWidget> {

  late ValueNotifier<TextEditingController> valueNotifier;

  @override
  void initState() {
    // TODO: implement initState
    DateTextFieldWidget.pressDeleteKey = false;

    if(widget.controller.text == ''){
      widget.controller.text = '____-__-__ __:__:__';
    }
    valueNotifier = ValueNotifier(widget.controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (_, controller, __){
        controller as TextEditingController;
        return RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event){
            if(event is RawKeyDownEvent){
              DateTextFieldWidget.pressDeleteKey = event.isKeyPressed(LogicalKeyboardKey.delete);
            }
          },
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [DateTimeFormatter(controller)],
            decoration: InputDecoration(
              labelText: widget.labelText,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.all(13),
            ),
            style: const TextStyle(fontSize: 12, height: 1.2),
            onTap: (){
              // 누른 부분만 selection
              int offset = controller.selection.baseOffset;
              if(offset < 4){
                controller.selection = const TextSelection(baseOffset: 0, extentOffset: 4);
              }else if(offset < 7){
                controller.selection = const TextSelection(baseOffset: 5, extentOffset: 7);
              }else if(offset < 10){
                controller.selection = const TextSelection(baseOffset: 8, extentOffset: 10);
              }else if(offset < 14){
                controller.selection = const TextSelection(baseOffset: 11, extentOffset: 13);
              }else if(offset < 17){
                controller.selection = const TextSelection(baseOffset: 14, extentOffset: 16);
              }else if(offset < 20){
                controller.selection = const TextSelection(baseOffset: 17, extentOffset: 19);
              }
            },
            onChanged: (val){
              if(widget.onChanged != null){
                widget.onChanged!(val);
              }
            },
          ),
        );
      }
    );
  }
}


class DateTimeFormatter extends TextInputFormatter {
  static const _maxChars = 19;
  TextEditingController controller;
  TextSelection? selection;

  DateTimeFormatter(this.controller);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = _format(newValue.text);
    return newValue.copyWith(text: text, selection: selection);
  }

  // 한글자 입력
  // 한글자 교체
  // 글자 삭제
  // 각 경우에 특수문자 체크


  // 부분 복붙
    // 같은 길이로 복사
    //


  String _format(String value) {
    selection = null;
    String newString = value;
    int startIndex = controller.selection.start;
    int removeLength = _maxChars - value.length;
    if(removeLength == 0){  // 한글자 교체
      if(startIndex == 4 || startIndex == 7){
        newString = newString.replaceRange(startIndex, startIndex+1, '-');
      }else if(startIndex == 10){
        newString = newString.replaceRange(startIndex, startIndex+1, ' ');
      }else if(startIndex == 13 || startIndex == 16){
        newString = newString.replaceRange(startIndex, startIndex+1, ':');
      }else{
        if(Util.checkRegNumber(newString[startIndex]) == false){
          newString = newString.replaceRange(startIndex, startIndex+1, '_');
        }
      }
    }else if(removeLength < 0) {  // 한글자 입력
      if(Util.checkRegNumber(newString[startIndex]) == false || startIndex >= 19){
        newString = newString.replaceRange(startIndex, startIndex+1, '');
        selection = TextSelection.fromPosition(TextPosition(offset: startIndex));
      }else{
        if(startIndex == 4 || startIndex == 7){ // -
          newString = newString.replaceRange(startIndex, startIndex+3, '-'+newString[startIndex]);
          selection = TextSelection.fromPosition(TextPosition(offset: startIndex+2));
        }else if(startIndex == 10){ // 공백
          newString = newString.replaceRange(startIndex, startIndex+3, ' '+newString[startIndex]);
          selection = TextSelection.fromPosition(TextPosition(offset: startIndex+2));
        }else if(startIndex == 13 || startIndex == 16){ // :
          newString = newString.replaceRange(startIndex, startIndex+3, ':'+newString[startIndex]);
          selection = TextSelection.fromPosition(TextPosition(offset: startIndex+2));
        }else{  // 년 월 일 시 분 초 입력
          newString = newString.replaceRange(startIndex+1, startIndex+2, '');
        }
      }
    }else{  // 한글자 이상 삭제
      int endIndex = controller.selection.end;
      if(startIndex == endIndex){ // 한글자씩 삭제
        if(DateTextFieldWidget.pressDeleteKey){
          if(startIndex == 4 || startIndex == 7){ // -
            newString = newString.replaceRange(startIndex, startIndex+1, '-_');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex+2));
          }else if(startIndex == 10){ // 공백
            newString = newString.replaceRange(startIndex, startIndex+1, ' _');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex+2));
          }else if(startIndex == 13 || startIndex == 16){ // :
            newString = newString.replaceRange(startIndex, startIndex+1, ':_');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex+2));
          }else{  // 년 월 일 시 분 초 입력
            newString = newString.replaceRange(startIndex, startIndex, '_');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex+1));
          }
        }else{
          if(startIndex == 5 || startIndex == 8){ // -
            newString = newString.replaceRange(startIndex-2, startIndex-1, '_-');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex-2));
          }else if(startIndex == 11){ // 공백
            newString = newString.replaceRange(startIndex-2, startIndex-1, '_ ');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex-2));
          }else if(startIndex == 14 || startIndex == 17){ // :
            newString = newString.replaceRange(startIndex-2, startIndex-1, '_:');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex-2));
          }else{  // 년 월 일 시 분 초 입력
            newString = newString.replaceRange(startIndex-1, startIndex-1, '_');
          }
        }
      }else{  // 블록 삭제
        String preStr = newString.substring(0, startIndex);
        String postStr = newString.substring(startIndex);
        String temp = '';
        for(int i=0; i<endIndex-startIndex; i++){
          if(controller.text[startIndex+i] == '-'){
            temp += '-';
          }else if(controller.text[startIndex+i] == ' '){
            temp += ' ';
          }else if(controller.text[startIndex+i] == ':'){
            temp += ':';
          }else{
            temp += '_';
          }
        }
        if(removeLength != endIndex - startIndex){  // 입력삭제이면
          if(Util.checkRegNumber(newString[startIndex]) == false){
            postStr = postStr.replaceRange(0, 1, '');
            selection = TextSelection.fromPosition(TextPosition(offset: startIndex));
          }else{
            String input = postStr.substring(0, 1);
            if(temp[0] != '-' && temp[0] != ' ' && temp[0] != ':'){
              temp = temp.replaceRange(0, 1, input);
            }
            postStr = postStr.replaceRange(0, 1, '');
          }
        }
        newString = preStr+temp+postStr;
      }
    }
    return newString;
  }
}