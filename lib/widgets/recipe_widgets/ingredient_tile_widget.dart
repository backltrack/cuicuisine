import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/data_model.dart';
import '../../models/local_model.dart';
import '../../themes/theme_mgr.dart';

class IngredientTile extends StatefulWidget {
  final Ingredient ingredient;
  final String locale;
  final double quantityRatio;

  const IngredientTile({
    super.key,
    required this.ingredient,
    required this.locale,
    this.quantityRatio=1.0
  });

  @override
  _IngredientTileState createState() => _IngredientTileState();
}

class _IngredientTileState extends State<IngredientTile> {
  late Ingredient ingredient;
  late Unit unitMgr;
  late String baseUnit;
  late String currentUnit;

  @override
  void initState() {
    super.initState();
    ingredient = widget.ingredient;
    baseUnit = ingredient.getUnit();
    currentUnit = baseUnit;
    unitMgr = Unit(widget.locale);
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

    final double density = ingredient.getDensity();
    double unitFactor = unitMgr.getConversionFactorForUnit(baseUnit, currentUnit, density);
    double quantity = (ingredient.quantity ?? 0.0) * widget.quantityRatio * unitFactor;

    List<String> compatibleUnits = unitMgr.getCompatibleUnitsForUnit(baseUnit, density);

    final theme = ThemeMgr.getTheme(context)!;

    return Container(
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(4)
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.only(left: 12),
        height: 45,
        child: Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width / 5,
                child: parseQuantity(quantity) == '0' ? const SizedBox() :
                  Text([
                    parseQuantity(quantity),
                    if (baseUnit != "none" && baseUnit != "quantity") currentUnit
                  ].join(" "), style: theme.textTheme.bodyLarge)
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(ingredient.getName(), style: theme.textTheme.bodyLarge),
              )
            ),
            if (compatibleUnits.length > 1)
              PopupMenuButton(
                icon: const FaIcon(FontAwesomeIcons.scaleBalanced, size: 20),
                itemBuilder: (ctx) => List<PopupMenuItem>.generate(compatibleUnits.length, (unitIndex) => PopupMenuItem(
                  child: Text(compatibleUnits[unitIndex], style: theme.textTheme.bodyLarge),
                  onTap: () {
                    setState(() {
                      currentUnit = compatibleUnits[unitIndex];
                    });
                  },
                )),
              )
          ],
        )
    );
  }
}
