import 'package:flutter/material.dart';

import '../../themes/theme_mgr.dart';

class BadgedIconButton extends StatefulWidget {
  final icon;
  final int number;
  final VoidCallback? onPressed;
  final Color? badgeColor;
  final Color? textColor;
  final bool hideBadgeOnNull;

  BadgedIconButton({
    Key? key,
    required this.icon,
    this.number = 0,
    this.onPressed,
    this.badgeColor = Colors.red,
    this.textColor = Colors.white,
    this.hideBadgeOnNull = true
  }) : super(key: key);

  @override
  _BadgedIconButtonState createState() => _BadgedIconButtonState(this.number);
}

class _BadgedIconButtonState extends State<BadgedIconButton> {

  int _badgeNumber;

  _BadgedIconButtonState(this._badgeNumber);

  @override
  Widget build(BuildContext context) {
    final double iconHeight = widget.icon.size == null ? ThemeMgr.getTheme(context)!.iconTheme.size! : widget.icon.size!;
    return Stack(
      children: [
        IconButton(
            onPressed: widget.onPressed ?? () {},
            icon: widget.icon
        ),
        if (!widget.hideBadgeOnNull || widget.hideBadgeOnNull && _badgeNumber > 0) Positioned(
          right: 4,
          top: 4,
          child: Container(
            decoration: BoxDecoration(
              color: widget.badgeColor,
              borderRadius: BorderRadius.circular(iconHeight / 3.5)
            ),
            constraints: BoxConstraints(
              minHeight: iconHeight / 1.75,
              minWidth: iconHeight / 1.75,
              maxHeight: iconHeight / 1.75,
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
