import 'package:flutter/material.dart';

class DropdownButtonWidget extends StatelessWidget {
  double? width;
  double? height;
  Color? color;
  Color borderColor;
  Object? value;
  List<dynamic> items;
  Function? onChanged;
  EdgeInsets padding;
  double iconSize;
  bool isExpanded;
  bool isDense;
  double itemFontSize;
  Color? itemColor;
  double? menuMaxHeight;

  DropdownButtonWidget({
    Key? key,
    this.width,
    this.height,
    this.color,
    this.borderColor=Colors.grey,
    this.value,
    this.items=const [],
    this.onChanged,
    this.padding=const EdgeInsets.all(5.0),
    this.iconSize=20,
    this.isExpanded=false,
    this.isDense=false,
    this.itemFontSize=13,
    this.itemColor,
    this.menuMaxHeight,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: borderColor)
      ),
      child: DropdownButton(
        focusColor: Colors.transparent,
        isDense: isDense,
        isExpanded:  isExpanded,
        underline: Container(),
        iconSize: iconSize,
        value: value,
        menuMaxHeight: menuMaxHeight,
        items: items.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.replaceAll("\r\n", ""), style: TextStyle(fontSize: itemFontSize, color: itemColor, height: 1),),
          );
        }).toList(),
        onChanged: onChanged!=null ? (value){
          onChanged!(value);
        } : null,
      ),
    );
  }
}
