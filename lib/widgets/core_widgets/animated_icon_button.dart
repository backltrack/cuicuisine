import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final Function()? onPressed;
  final Widget icon;

  AnimatedIconButton({super.key, this.onPressed, required this.icon});

  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController iconAnimationController;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500)
    );
  }

  @override
  void dispose() {
    iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: CurvedAnimation(curve: Curves.easeInOut, parent: iconAnimationController),
      child: IconButton(
        onPressed: () async {
          if (widget.onPressed != null) {
            setState(() {
              iconAnimationController
                ..forward(from: 0.0)
                ..repeat();
            });

            await widget.onPressed!();

            setState(() {
              iconAnimationController.stop();
            });
          }
        },
        icon: widget.icon,
      )
    );
  }
}