import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../themes/theme_mgr.dart';

class MyOutlinedButton extends StatelessWidget {
  final IconData? icon;
  final String text;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;

  const MyOutlinedButton({super.key, this.icon, required this.text, this.padding, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: OutlinedButton(
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
              ...[FaIcon(icon, size: 15, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
              const SizedBox(width: 5)],
              Text(text.toUpperCase(), style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge)
            ],
          )
      ),
    );
  }
}
