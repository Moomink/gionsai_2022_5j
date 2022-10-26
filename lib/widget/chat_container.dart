import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class ChatContainer extends StatelessWidget {
  final Widget child;
  final bool isImage;

  ChatContainer({required this.child, this.isImage = false});

  @override
  Widget build(BuildContext context) {

    final Size size = MediaQuery.of(context).size;
    if (isImage) {
      return Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: size.width * 0.7),
              child: Container(margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10), child:child)));
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
