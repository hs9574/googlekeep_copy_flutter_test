import 'package:flutter/material.dart';
import 'package:fastapi_project/firebase_login/screen/user_page.dart';
import 'package:fastapi_project/utils/util.dart';

class TextFieldAppBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final double? height;
  final Color? color;
  final List<Widget> prefixIcon;
  final String? hintText;
  final Function(String)? onSubmitted;
  final Function()? onTapTextField;
  TextFieldAppBarWidget({
    Key? key,
    this.controller,
    this.height =45,
    this.color,
    this.prefixIcon = const [],
    this.hintText,
    this.onSubmitted,
    this.onTapTextField
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.only(left: 15, right: 10),
      decoration: BoxDecoration(
        color: color ?? const Color(0xfff4f7fc),
        borderRadius: BorderRadius.circular(30)
      ),
      child: Row(
        children: [
          const Icon(Icons.search),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(13),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: onSubmitted,
              onTap: onTapTextField,
            ),
          ),
          Row(
            children: prefixIcon,
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: (){
              showDialog(
                context: context,
                builder: (context){
                  return const UserPage();
                }
              );
            },
            child: const Icon(Icons.account_circle, size: 35)
            // SizedBox(
            //   height: 35,
            //   width: 35,
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(30),
            //     child: Image.network(user.photoURL??'', fit: BoxFit.cover),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
