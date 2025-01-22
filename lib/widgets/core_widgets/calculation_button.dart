import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/recipe_widgets/QuantityMultiplierDialog.dart';

class CalculationButtonWidget extends StatefulWidget {
  final double value;
  final Function(double) onValueChanged;
  const CalculationButtonWidget({super.key, required this.onValueChanged, this.value=0});

  @override
  State<CalculationButtonWidget> createState() => _CalculationButtonWidgetState();
}

class _CalculationButtonWidgetState extends State<CalculationButtonWidget> {
  bool _isEnabled = false;
  double _value = 0;

  @override
  void initState() {
    super.initState();

    setState(() {
      _value = widget.value;
      _isEnabled = _value != 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_value != 1 ? _value.toStringAsFixed(3) : ''),
        IconTheme(
          data: _isEnabled ? ThemeMgr.getTheme(context)!.iconTheme.copyWith(color: ThemeMgr.getTheme(context)!.primaryColor) : ThemeMgr.getTheme(context)!.iconTheme.copyWith(color: Colors.grey),
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.calculator),
            onPressed: () async {
              var newValue = await showQuantityMultiplierDialog(context: context, currentCoefficient: _value);
              if (newValue != null) {
                if (newValue != _value && newValue > 0) {
                  setState(() {
                    _isEnabled = newValue != 1;

                    _value = newValue;
                  });
                  await widget.onValueChanged(newValue);
                }
              }
            },
          )
        )
      ],
    );
  }
}
