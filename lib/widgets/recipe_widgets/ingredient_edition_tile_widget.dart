import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/data_model.dart';
import '../../models/local_model.dart';
import '../../themes/theme_mgr.dart';

class IngredientEditionTile extends StatefulWidget {
  final Ingredient ingredient;
  final String locale;
  final Function()? onEdit;
  final Function()? onRemove;

  const IngredientEditionTile({
    super.key,
    required this.ingredient,
    required this.locale,
    this.onEdit,
    this.onRemove
  });

  @override
  _IngredientEditionTileState createState() => _IngredientEditionTileState();
}

class _IngredientEditionTileState extends State<IngredientEditionTile> {
  late Ingredient ingredient;
  late Unit unitMgr;

  @override
  void initState() {
    super.initState();

    setState(() {
      ingredient = widget.ingredient;
      unitMgr = Unit(widget.locale);
    });
  }

  String parseQuantity(double quantity) {
    if (quantity.round().toDouble() == quantity) {
      return quantity.round().toString();
    } 
    else if ((quantity * 10).round().toDouble() == quantity * 10) {
      return quantity.toStringAsFixed(1);
    }
    else if ((quantity * 100).round().toDouble() == quantity * 100) {
      return quantity.toStringAsFixed(2);
    }
    else {
      return quantity.toStringAsFixed(3);
    }
  }

  @override
  Widget build(BuildContext context) {
    double quantity = double.parse(ingredient.quantity.toString());

    return Container(
        decoration: BoxDecoration(
            color: ThemeMgr.getTheme(context)!.colorScheme.surface,
            borderRadius: BorderRadius.circular(4)
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(left: 12),
        height: 45,
        child: Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: Text([
                  parseQuantity(quantity),
                  if (ingredient.getUnit() != "none" && ingredient.getUnit() != "quantity") ingredient.getUnit()
                ].join(" "), style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge)
            ),
            Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(ingredient.getName(), style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                )
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.pen, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: FaIcon(FontAwesomeIcons.solidTrashCan, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
              onPressed: widget.onRemove
            ),
          ],
        )
    );
  }
}
