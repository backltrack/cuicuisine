import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/recipe_widgets/quantity_name_dialog.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final int quantity;
  final String quantityType;
  final Function(int)? onQuantityChanged;
  final Function(String)? onTypeChanged;
  final bool isEdition;

  const QuantitySelectorWidget({Key? key, required this.quantity, required this.quantityType, this.onQuantityChanged, this.onTypeChanged, this.isEdition=false}) : super(key: key);

  @override
  _QuantitySelectorWidgetState createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  int _quantity = 0;
  String _quantityType = "";

  @override
  void initState() {
    super.initState();

    setState(() {
      _quantity = widget.quantity;
      _quantityType = widget.quantityType;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    setState(() {
                      _quantity = _quantity - 1;
                    });
                    if (widget.onQuantityChanged != null) widget.onQuantityChanged!(_quantity);
                  }
                },
                icon: Icon(Icons.remove, color: ThemeMgr.getTheme(context)!.colorScheme.background)
            ),
            widget.isEdition ?
            TextButton(
              onPressed: () async {
                String? newType = await showQuantityNameDialog(context: context, currentType: _quantityType);
                if (newType != null) {
                  print(newType);
                  if (newType != "" && newType != _quantityType) {
                    setState(() {
                      _quantityType = newType;
                    });
                    if (widget.onTypeChanged != null) widget.onTypeChanged!(_quantityType);
                  }
                }
              },
              child: Text(
                  widget.quantityType != "" ?
                  _quantity.toString() + "  " + _quantityType
                      : _quantity.toString() + "  " + S.of(context).ingredient_widget_quantity_type,
                  style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: ThemeMgr.getTheme(context)!.colorScheme.background)),
            )
                : Text(
                widget.quantityType != "" ?
                _quantity.toString() + "  " + _quantityType
                    : _quantity.toString() + "  " + S.of(context).ingredient_widget_quantity_type,
                style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: ThemeMgr.getTheme(context)!.colorScheme.background)
            ),
            IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _quantity = _quantity + 1;
                  });
                  if (widget.onQuantityChanged != null) widget.onQuantityChanged!(_quantity);
                },
                icon: Icon(Icons.add, color: ThemeMgr.getTheme(context)!.colorScheme.background)
            )
          ],
        ),
    );
  }
}
