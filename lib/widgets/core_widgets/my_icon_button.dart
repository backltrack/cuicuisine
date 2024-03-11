import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget icon;

  MyIconButton({Key? key, this.onPressed, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconThemeData iconThemeData = IconTheme.of(context);
    return IconButton(
      onPressed: onPressed,
      iconSize: iconThemeData.size != null ? iconThemeData.size! : 20, icon: icon,
    );
  }
}

