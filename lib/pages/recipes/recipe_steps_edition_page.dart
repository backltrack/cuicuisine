import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../generated/l10n.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../../database/database_mgr.dart';
import '../../models/data_model.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../../widgets/recipe_widgets/recipe_steps_edition_widget.dart';

class RecipeStepsEditionPage extends StatefulWidget {
  const RecipeStepsEditionPage({Key? key}) : super(key: key);

  @override
  _RecipeStepsEditionPageState createState() => _RecipeStepsEditionPageState();
}

class _RecipeStepsEditionPageState extends State<RecipeStepsEditionPage> {
  List<RecipeStep> newSteps = [];
  bool isInit = false;

  HtmlEditorController htmlEditorController = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String recipeId = routeArgs['recipeId'];
    final List<RecipeStep> steps = routeArgs['steps'];

    if (!isInit) {
      newSteps.addAll(steps);
      isInit = true;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).steps_edition_title),
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
                  Text(S.of(context).recipe_edition_update, style: const TextStyle(fontWeight: FontWeight.bold),),
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
        body: SingleChildScrollView(
            child: Column(
              children: [
                RecipeStepsEditionWidget(
                  key: UniqueKey(),
                  steps: newSteps,
                  onStepChanged: (Map<String, dynamic> value) {
                    setState(() {
                      print(value['step']);
                      print(value['index']);
                      newSteps[value['index']].step = value['step'];
                    });
                  },
                  onAddStep: (RecipeStep newStep) {
                    setState(() {
                      newSteps.add(newStep);
                    });
                  },
                  onRemoveStep: (int index) {
                    setState(() {
                      newSteps.removeAt(index);
                    });
                  },
                ),
                const SizedBox(height: 80)
              ],
            )
        ),
        floatingActionButton: FloatingActionButton.extended(
            label: Text(S.of(context).recipe_edition_update),
            onPressed: () async {
              print(steps);
              DatabaseMgr().localMgr.updateRecipe(
                recipeId,
                RecipeUpdate(
                  id: recipeId,
                  steps: newSteps
                )
              );

              Navigator.pop(context, 'update');
            }
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat
    );
  }
}
