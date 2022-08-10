import 'package:flutter/material.dart';

class DragBottomSheetWidget extends StatefulWidget {
  final Widget child;
  final double minHeight;
  final double maxHeight;
  final Color backgroundColor;
  const DragBottomSheetWidget({
    Key? key,
    required this.child,
    this.minHeight = 30,
    required this.maxHeight,
    this.backgroundColor = Colors.white
  }) : super(key: key);

  @override
  State<DragBottomSheetWidget> createState() => _DragBottomSheetWidgetState();
}

class _DragBottomSheetWidgetState extends State<DragBottomSheetWidget> {
  double minHeight = 0;
  double maxHeight = 0;
  double onPanHeight = 0;
  bool isDragSheet = false;

  @override
  void initState() {
    super.initState();
    minHeight = widget.minHeight;
    maxHeight = widget.maxHeight;
    onPanHeight = minHeight;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: onPanHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const  BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 5,
            offset: const Offset(0, 3)
          )
        ]
      ),
      child: SingleChildScrollView(
        physics: const  NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            GestureDetector(
              onPanEnd: (e){
                setState((){
                  if(isDragSheet == false && onPanHeight > minHeight){
                    isDragSheet = true;
                    onPanHeight = maxHeight;
                  }
                  if(isDragSheet == true && onPanHeight < maxHeight){
                    isDragSheet = false;
                    onPanHeight = minHeight;
                  }
                });
              },
              onPanUpdate: (e){
                setState((){
                  onPanHeight = MediaQuery.of(context).size.height - e.globalPosition.dy;
                  if(onPanHeight < minHeight){
                    onPanHeight = minHeight;
                  }
                  if(onPanHeight > maxHeight){
                    onPanHeight = maxHeight;
                  }
                });
              },
              child: Container(
                height: minHeight,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                child: const Icon(Icons.maximize, color: Colors.black54),
              ),
            ),
            SingleChildScrollView(
              physics: isDragSheet ? null : const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
