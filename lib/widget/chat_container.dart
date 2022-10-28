import 'package:flutter/material.dart';

class ChatContainer extends StatelessWidget {
  final Widget child;
  final bool isImage;

  const ChatContainer({super.key, required this.child, this.isImage = false});


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    if (isImage) {
      return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 0.7),
              child: GestureDetector(
                  onTap:() => showPreviewImage(context,image: child),
                  child: Container(
                      margin:
                      const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                      child: child))));
    } else {
      return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 0.7),
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    )),
                child: child,
              )));
    }
  }
}


//https://qiita.com/ling350181/items/adfebd6f7c648084d1b5
void showPreviewImage(BuildContext context, {
  required Widget image,
}) {
  showDialog(
    barrierDismissible: true,
    barrierLabel: '閉じる',
    context: context,
    builder: (context) {
      return Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 5,
                  child: image,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
              ),
            ]
            ,
          )
          ,
        ]
        ,
      );
    },
  );
}
