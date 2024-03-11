import 'package:flutter/material.dart';

import '../../themes/colors.dart';
import '../../themes/theme_mgr.dart';

class SocialButton extends StatelessWidget {
  final Widget? child;
  final Function()? onPressed;
  const SocialButton({Key? key, this.child, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      margin: EdgeInsets.symmetric(vertical: 8),
      height: 48,
      width: double.infinity,
      child: RawMaterialButton(
        // email sign in button
          child: child,
          shape: StadiumBorder(),
          fillColor: onPressed == null ? Colors.grey: ThemeMgr.getTheme(context)!.primaryColor,
          textStyle: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: DarkColors.writingColor),
          onPressed: onPressed
      ),
    );
  }
}