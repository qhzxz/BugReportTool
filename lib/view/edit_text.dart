
import 'package:flutter/material.dart';

Container EditText({String? hint, int? maxLine, int ?minLine,ValueChanged<String>? onChanged,TextInputType?keyboardType,String? defaultValue}) {
  return Container(
    margin: EdgeInsets.only(top: 10, left: 50),
    child: Row(

      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: EdgeInsets.only(right: 25,top: 10),
            alignment: Alignment.topLeft,
            child: SizedBox(
                width: 200,
                child: Text(hint??"", textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20)))),
        SizedBox(
          width: 500,
            child: TextFormField(
                controller: TextEditingController(text: defaultValue),
                decoration: InputDecoration(filled: true,fillColor: Colors.white,border: OutlineInputBorder()),
                maxLines: maxLine,
                minLines: minLine,
                keyboardType: keyboardType,
                onChanged: onChanged)
        ),
      ],
    ),
  );
}