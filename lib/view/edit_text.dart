
import 'package:flutter/material.dart';

Container EditText(String hint, int? maxLine, int ?minLine,ValueChanged<String>? onChanged,TextInputType?keyboardType ) {
  return Container(
    margin: EdgeInsets.only(top: 10, left: 50),
    child: Row(
      children: [
        Container(margin: EdgeInsets.only(right: 25),alignment: Alignment.topLeft, child: SizedBox(
            width: 200, child: Text(hint,style: TextStyle(fontSize: 20),))),
        SizedBox(
          width: 500,
            child: TextField(maxLines: maxLine,
                minLines: minLine,
                keyboardType: keyboardType,
                onChanged: onChanged)
        ),
      ],
    ),
  );
}