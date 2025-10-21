import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String text;
  LoadingDialog({Key? key, this.text = "加载中..."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, // 背景透明
      child: Center( // 中间弹出
        child: SizedBox(
          width: 250,
          height: 150,
          child: Container(
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(text, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}