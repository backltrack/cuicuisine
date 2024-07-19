import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/theme_mgr.dart';

import '../../models/data_model.dart';

class VariantWidget extends StatefulWidget {
  final Variant variant;
  final Function()? onRemove;

  VariantWidget({Key? key, required this.variant, this.onRemove}) : super(key: key);

  @override
  State<VariantWidget> createState() => _VariantWidgetState();
}

class _VariantWidgetState extends State<VariantWidget> {
  String? initials;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    List<Widget> orderedVariantWidget = [
      CircleAvatar(
          backgroundColor: ThemeMgr.getTheme(context)!.primaryColorDark,
          child: Text(isLoaded ? initials! : "")
      ),
      Container(
        width: MediaQuery.of(context).size.width - 16-3*12-48,
        constraints: const BoxConstraints(
            minHeight: 48
        ),
        padding: const EdgeInsets.only(left: 12),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
            color: ThemeMgr.getTheme(context)!.colorScheme.background,
            borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Text(widget.variant.variant)
            ),
            if (widget.variant.userId == DatabaseMgr().localMgr.getUserId())
              IconButton(
                  onPressed: () {
                    if (widget.onRemove != null) {
                      widget.onRemove!();
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.times, size: 14),
                  padding: EdgeInsets.zero
              )
          ],
        ),
      )
    ];

    return isLoaded ?
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.variant.userId == DatabaseMgr().localMgr.getUserId() ? orderedVariantWidget.reversed.toList() : orderedVariantWidget,
          ),
        )
        :
        const Center(
          child: CircularProgressIndicator(),
        );
  }
}
