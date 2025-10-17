import 'package:flutter/cupertino.dart';

Container SwitchBox({
  String? hint,
  bool? isOpen,
  ValueChanged<bool>? onChanged,
}) {
  return Container(
    margin: EdgeInsets.only(top: 10, left: 50),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(right: 25),
          child: SizedBox(
            width: 200,
            child: Text(hint ?? "", style: TextStyle(fontSize: 20)),
          ),
        ),
        CupertinoSwitch(value: isOpen ?? false, onChanged: onChanged),
      ],
    ),
  );
}
