import 'package:flutter/material.dart';

class CircularIconButton extends StatefulWidget {
  const CircularIconButton({super.key, required this.icon, this.color, this.onPressed});

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
      style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: widget.color
      ),
      onPressed: widget.onPressed,
      child: widget.icon
    );
  }
}
