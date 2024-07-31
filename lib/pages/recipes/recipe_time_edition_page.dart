import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/recipe_widgets/recipe_time_widget.dart';

import '../../widgets/core_widgets/alert_dialog.dart';

class RecipeTimeEditionPage extends StatefulWidget {

  const RecipeTimeEditionPage({Key? key}) : super(key: key);

  @override
  _RecipeTimeEditionPageState createState() => _RecipeTimeEditionPageState();
}

class _RecipeTimeEditionPageState extends State<RecipeTimeEditionPage> {
  int _preparationTime = 0;
  int _waitingTime = 0;
  int _cookingTime = 0;

  bool shouldInit = true;

  final TextEditingController preparationTextEditingController = TextEditingController();
  final TextEditingController waitingTextEditingController = TextEditingController();
  final TextEditingController cookingTextEditingController = TextEditingController();

  @override
  void dispose() {
    preparationTextEditingController.dispose();
    waitingTextEditingController.dispose();
    cookingTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String recipeId = routeArgs['id']!;
    if (shouldInit) {
      _preparationTime = routeArgs['preparation']!;
      _waitingTime = routeArgs['waiting']!;
      _cookingTime = routeArgs['cooking']!;

      if (_preparationTime > 0) preparationTextEditingController.text = _preparationTime.toString();
      if (_waitingTime > 0) waitingTextEditingController.text = _waitingTime.toString();
      if (_cookingTime > 0) cookingTextEditingController.text = _cookingTime.toString();

      shouldInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).recipe_edition_time_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            bool returnValue = false;
            await showAlertDialog(
              context: context,
              title: S.of(context).popup_loose_data_title,
              description: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).popup_loose_data_1, textAlign: TextAlign.center),
                  Text(S.of(context).recipe_edition_update, style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(S.of(context).popup_loose_data_2, textAlign: TextAlign.center),
                  Text(S.of(context).popup_loose_data_3, textAlign: TextAlign.center)
                ],
              ),
            ).then((value) {
              print(value);
              if (value != null && value) {
                returnValue = true;
              }
            });

            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop(returnValue);
            });
          }
        ),
      ),
      body: Column(
        children: [
          RecipeTimeWidget(
              preparationTime: _preparationTime,
              waitingTime: _waitingTime,
              cookingTime: _cookingTime
          ),

          const SizedBox(
              height: 12
          ),

          MyTextField(
            keyboardType: TextInputType.number,
            textEditingController: preparationTextEditingController,
            autofocus: true,
            label: S.of(context).time_widget_preparation,
            icon: FontAwesomeIcons.clock,
            suffixText: S.of(context).time_minutes_abr,
            onChanged: (String val) {
              int? v = int.tryParse(val);
              v ??= 0;
              setState(() {
                _preparationTime = v!;
              });
            },
          ),
          MyTextField(
            keyboardType: TextInputType.number,
            textEditingController: waitingTextEditingController,
            label: S.of(context).time_widget_waiting,
            icon: FontAwesomeIcons.clock,
            suffixText: S.of(context).time_minutes_abr,
            onChanged: (String val) {
              int? v = int.tryParse(val);
              v ??= 0;
              setState(() {
                _waitingTime = v!;
              });
            },
          ),
          MyTextField(
            keyboardType: TextInputType.number,
            textEditingController: cookingTextEditingController,
            label: S.of(context).time_widget_cooking,
            icon: FontAwesomeIcons.clock,
            suffixText: S.of(context).time_minutes_abr,
            onChanged: (String val) {
              int? v = int.tryParse(val);
              v ??= 0;
              setState(() {
                _cookingTime = v!;
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          label: Text(S.of(context).recipe_edition_update),
          onPressed: () async {
            DatabaseMgr().localMgr.updateRecipe(recipeId,
              RecipeUpdate(
                id: recipeId,
                preparationTime: _preparationTime,
                waitingTime: _waitingTime,
                cookingTime: _cookingTime
              )
            );

            Navigator.pop(context, 'update');
          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}
