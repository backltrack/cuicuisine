import 'package:flutter/material.dart';

class CircularIconButton extends StatefulWidget {
  const CircularIconButton({Key? key, required this.icon, this.color, this.onPressed}) : super(key: key);

  final Widget icon;
  final Color? color;
  final Function()? onPressed;

  @override
  State<CircularIconButton> createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<CircularIconButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: widget.icon,
      style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: widget.color
      ),
      onPressed: widget.onPressed
    );
  }
}
