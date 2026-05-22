import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/recipe_widgets/quantity_name_dialog.dart';
import '../../utilities/logger.dart';

final _log = Logger('QuantitySelectorWidget');

class QuantitySelectorWidget extends StatefulWidget {
  final int quantity;
  final String quantityType;
  final Function(int)? onQuantityChanged;
  final Function(String)? onTypeChanged;
  final bool isEdition;

  const QuantitySelectorWidget({super.key, required this.quantity, required this.quantityType, this.onQuantityChanged, this.onTypeChanged, this.isEdition=false});

  @override
  _QuantitySelectorWidgetState createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  int _quantity = 0;
  String _quantityType = "";

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _quantityType = widget.quantityType;
  }

  @override
  Widget build(BuildContext context) {
    _log.fine("build: qty=$_quantity type=$_quantityType");
    return Container(
        height: 35,
        //width: double.infinity,
        decoration: BoxDecoration(
            color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
            borderRadius: BorderRadius.circular(4)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (_quantity > 1) {
                      _quantity = _quantity - 1;
                    if (widget.onQuantityChanged != null) widget.onQuantityChanged!(_quantity);
                  }
                },
                icon: Icon(Icons.remove, color: ThemeMgr.getTheme(context)!.colorScheme.surface)
            ),
            widget.isEdition ?
            TextButton(
              onPressed: () async {
                String? newType = await showQuantityNameDialog(context: context, currentType: _quantityType);
                if (newType != null) {
                  _log.fine("quantity type changed: $newType");
                  if (newType != "" && newType != _quantityType) {
                    _quantityType = newType;
                    if (widget.onTypeChanged != null) widget.onTypeChanged!(_quantityType);
                  }
                }
              },
              child: Text(
                  widget.quantityType != "" ?
                  "$_quantity  $_quantityType"
                      : "$_quantity  ${S.of(context).ingredient_widget_quantity_type}",
                  style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: ThemeMgr.getTheme(context)!.colorScheme.surface)),
            )
                : Text(
                widget.quantityType != "" ?
                "$_quantity  $_quantityType"
                    : "$_quantity  ${S.of(context).ingredient_widget_quantity_type}",
                style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: ThemeMgr.getTheme(context)!.colorScheme.surface)
            ),
            IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                    _quantity = _quantity + 1;
                  if (widget.onQuantityChanged != null) widget.onQuantityChanged!(_quantity);
                },
                icon: Icon(Icons.add, color: ThemeMgr.getTheme(context)!.colorScheme.surface)
            )
          ],
        ),
    );
  }
}
