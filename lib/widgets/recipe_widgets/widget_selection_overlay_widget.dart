import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WidgetSelectionOverlay extends StatefulWidget {

  final Widget widget;
  final bool editModeController;
  final VoidCallback? onTap;
  final double borderRadius;
  final double margin;
  final double opacity;

  const WidgetSelectionOverlay({Key? key, required this.widget, required this.editModeController, this.onTap, this.borderRadius=12, this.margin=8, this.opacity=0.9}) : super(key: key);

  @override
  _WidgetSelectionOverlayState createState() => _WidgetSelectionOverlayState();
}

class _WidgetSelectionOverlayState extends State<WidgetSelectionOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.widget,
        if (widget.editModeController) Positioned.fill(
          child: Opacity(
            opacity: widget.opacity,
            child: InkWell(
              child: Container(
                margin: EdgeInsets.only(left: widget.margin, top: widget.margin, right: widget.margin),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(widget.borderRadius)
                ),
                child: Center(
                  child: CircleAvatar(
                    child: FaIcon(FontAwesomeIcons.edit, color: Colors.grey),
                    radius: 24,
                    backgroundColor: Colors.grey.shade600,
                  ),
                ),
              ),
              onTap: () {
                if (widget.onTap != null) widget.onTap!();
              },
            )
          )
        )
      ],
    );
  }
}
