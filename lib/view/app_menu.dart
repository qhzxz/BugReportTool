
import 'package:flutter/material.dart';

Container AppMenu(String hint,
    List<DropdownMenuItem<String>> items, String? value,
    ValueChanged<String?>? onChanged) {
  return Container(margin: EdgeInsets.only(top: 10, left: 50), child: Row(
    children: [
      Container(
        margin: EdgeInsets.only(right: 25),
        child: SizedBox(
            width: 200, child: Text(hint, style: TextStyle(fontSize: 20),)),
      ),
      SizedBox(width: 500, child: DropdownButton<String>(
        isExpanded: true,
          alignment: Alignment.centerLeft,
          hint: Text('None'),
          items: items,
          value: value,
          style: TextStyle(fontSize: 18, color: Colors.black),
          icon: Icon(Icons.arrow_drop_down),
          onChanged: onChanged
      ))
    ],
  ));
}