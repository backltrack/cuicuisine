import 'package:flutter/material.dart';

import '../../themes/theme_mgr.dart';

class BadgedIconButton extends StatefulWidget {
  final icon;
  final int number;
  final VoidCallback? onPressed;
  final Color? badgeColor;
  final Color? textColor;
  final bool hideBadgeOnNull;

  const BadgedIconButton({
    super.key,
    required this.icon,
    this.number = 0,
    this.onPressed,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.hideBadgeOnNull = true
  });

  @override
  _BadgedIconButtonState createState() => _BadgedIconButtonState(number);
}

class _BadgedIconButtonState extends State<BadgedIconButton> {

  final int _badgeNumber;

  _BadgedIconButtonState(this._badgeNumber);

  @override
  Widget build(BuildContext context) {
    final double iconHeight = widget.icon.size == null ? ThemeMgr.getTheme(context)!.iconTheme.size! : widget.icon.size!;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        IconButton(
            onPressed: widget.onPressed ?? () {},
            icon: widget.icon
        ),
        if (!widget.hideBadgeOnNull || widget.hideBadgeOnNull && _badgeNumber > 0) Positioned(
          right: 0,
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              color: widget.badgeColor,
              borderRadius: BorderRadius.circular(iconHeight / 3)
            ),
            constraints: BoxConstraints(
              minHeight: iconHeight / 1.7,
              minWidth: iconHeight / 1.5,
              maxHeight: iconHeight / 1.5,
            ),
            alignment: AlignmentDirectional.center,
            child: Container(
              margin: EdgeInsetsDirectional.only(top: 1),
              child: Text(
                _badgeNumber.toString(),
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: iconHeight / 2
                ),
              )
            ),
          )
        )
      ],
    );
  }
}
