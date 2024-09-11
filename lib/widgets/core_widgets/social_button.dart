import 'package:flutter/material.dart';

import '../../themes/colors.dart';
import '../../themes/theme_mgr.dart';

class SocialButton extends StatelessWidget {
  final Widget? child;
  final Function()? onPressed;
  const SocialButton({super.key, this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 48,
      width: double.infinity,
      child: RawMaterialButton(
        // email sign in button
          shape: const StadiumBorder(),
          fillColor: onPressed == null ? Colors.grey: ThemeMgr.getTheme(context)!.primaryColor,
          textStyle: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: DarkColors.writingColor),
          onPressed: onPressed,
          child: child
      ),
    );
  }
}