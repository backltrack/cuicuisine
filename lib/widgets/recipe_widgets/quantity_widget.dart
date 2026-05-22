import 'package:flutter/material.dart';
import '../../utilities/custom_enum.dart';
import '../../widgets/recipe_widgets/quantity_selector_widget.dart';

import '../core_widgets/calculation_button.dart';
import '../../utilities/logger.dart';

final _log = Logger('QuantityWidget');

class QuantityEditorWidget extends StatefulWidget {
  final int quantity;
  final String quantityType;
  final double multiplier;
  final Function(int)? onQuantityChanged;
  final Function(String)? onTypeChanged;
  final Function(double)? onMultiplierChanged;
  final SimpleAlignment location;
  final bool isEdition;
  final bool showQuantityMultiplier;

  const QuantityEditorWidget({super.key, required this.quantity, required this.quantityType, this.multiplier=1, this.onQuantityChanged, this.onTypeChanged, this.onMultiplierChanged, this.location=SimpleAlignment.left, this.isEdition=false, this.showQuantityMultiplier=true});

  @override
  _QuantityEditorWidgetState createState() => _QuantityEditorWidgetState();
}

class _QuantityEditorWidgetState extends State<QuantityEditorWidget> {
  int _quantity = 0;
  String _quantityType = "";
  double _multiplier = 1;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _quantityType = widget.quantityType;
    _multiplier = widget.multiplier;
  }

  @override
  Widget build(BuildContext context) {
    _log.fine("build: qty=$_quantity type=$_quantityType");
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.location == SimpleAlignment.left)
            ...[
              SizedBox(
                child: QuantitySelectorWidget(
                  quantity: _quantity,
                  quantityType: _quantityType,
                  isEdition: widget.isEdition,
                  onTypeChanged: (String newType) {
                      _quantityType = newType;
                    if (widget.onTypeChanged != null) widget.onTypeChanged!(_quantityType);
                  },
                  onQuantityChanged: (int newQuantity) {
                      _quantity = newQuantity;
                    if (widget.onQuantityChanged != null) widget.onQuantityChanged!(_quantity);
                  },
                )
              ),

              const Spacer(),

              if (widget.showQuantityMultiplier && !widget.isEdition)
                CalculationButtonWidget(
                  key: const ValueKey('coefficient_button'),
                  value: _multiplier,
                  onValueChanged: (double value) {
                    _multiplier = value;
                    if (widget.onMultiplierChanged != null) widget.onMultiplierChanged!(_multiplier);
                  },
                )
            ]
          else
            ...[
              if (widget.showQuantityMultiplier && !widget.isEdition)
                CalculationButtonWidget(
                  key: const ValueKey('coefficient_button2'),
                  value: _multiplier,
                  onValueChanged: (double value) {
                    _multiplier = value;
                    if (widget.onMultiplierChanged != null) widget.onMultiplierChanged!(_multiplier);
                  },
                ),
              const Spacer(),
              QuantitySelectorWidget(
                quantity: _quantity,
                quantityType: _quantityType,
                onTypeChanged: (String newType) {
                    _quantityType = newType;
                },
                onQuantityChanged: (int newQuantity) {
                    _quantity = newQuantity;
                },
              )
            ]
        ]
    );
  }
}
