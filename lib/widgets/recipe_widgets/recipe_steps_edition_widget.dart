import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/time_functions.dart';
import '../../widgets/recipe_widgets/widget_selection_overlay_widget.dart';

import '../../models/model.dart';
import '../core_widgets/circular_button.dart';
import '../core_widgets/my_outlined_button.dart';

class RecipeStepsEditionWidget extends StatefulWidget {
  final List<RecipeStep> steps;
  final Function(Map<String, dynamic>)? onStepChanged;
  final Function(RecipeStep)? onAddStep;
  final Function(int)? onRemoveStep;
  RecipeStepsEditionWidget({Key? key, required this.steps, this.onStepChanged, this.onAddStep, this.onRemoveStep}) : super(key: key);

  @override
  _RecipeStepsEditionWidgetState createState() => _RecipeStepsEditionWidgetState();
}

class _RecipeStepsEditionWidgetState extends State<RecipeStepsEditionWidget> {
  List<RecipeStep> newSteps = [];
  bool isInit = false;
  
  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      newSteps.addAll(widget.steps);
      isInit = true;
    }

    return Container(
      decoration: BoxDecoration(
        color: ThemeMgr.getTheme(context)!.cardColor,
        borderRadius: BorderRadius.circular(12)
      ),
      // width: double.infinity,
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(left: 8, top: 8, right: 8),
      child: Column(
        children: [
          // title and zoom buttons
          Container(
            width: double.infinity,
            child: Center(
              child:Text(
                S.of(context).steps_widget_title,
                style: ThemeMgr.getTheme(context)!.textTheme.headline2,
              ),
            ),
          ),

          SizedBox(height: 12),
          // generate steps
          Container(
            width: double.infinity,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...List<Widget>.generate(newSteps.length, (index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              S.of(context).steps_widget_step + " ${index+1}",
                              style: ThemeMgr.getTheme(context)!.textTheme.headline3
                          ),
                          CircularIconButton(
                            icon: FaIcon(FontAwesomeIcons.trashAlt, size: 18, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
                            color: ThemeMgr.getTheme(context)!.colorScheme.background,
                            onPressed: () {
                              if (widget.onRemoveStep != null)
                                widget.onRemoveStep!(index);
                            },
                          )
                        ],
                      ),

                      SizedBox(height: 4),

                      WidgetSelectionOverlay(
                        widget: Container(
                          constraints: BoxConstraints(
                              minHeight: 56
                          ),
                          child: Html(
                            data: newSteps[index].step,
                          )
                        ),
                        borderRadius: 2,
                        margin: 2,
                        editModeController: true,
                        opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                        onTap: () {
                          Navigator.pushNamed(context, ModalRoute.of(context)!.settings.name! + "/$index", arguments: {
                            "stepNumber": index,
                            "stepDescription": newSteps[index].step
                          }).then((value) async {
                            if (value != null) {
                              if (widget.onStepChanged != null) {
                                setState(() {
                                  widget.onStepChanged!({
                                    'step': value.toString().trim().replaceAll("<p></p>", "").replaceAll("<div><br></div>", ""),
                                    'index': index
                                  });
                                });
                              }
                            }
                          });
                        },
                      ),

                      SizedBox(height: 8),

                      InkWell(
                        onTap: () async {
                          var resultingDuration = await showDurationPicker(
                            context: context,
                            initialTime: Duration(minutes: newSteps[index].time),
                            snapToMins: 5.0,
                          );
                          if (resultingDuration != null)
                          {
                            setState(() {
                              newSteps[index].time = resultingDuration.inMinutes;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: null,
                              icon: FaIcon(Icons.timer_outlined, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
                            ),
                            Text(minutesToTime(newSteps[index].time))
                          ],
                        )
                      ),
                    ],
                  );
                }),

                // Last item: Add Button
                MyOutlinedButton(
                  text: S.of(context).add_button,
                  icon: FontAwesomeIcons.plus,
                  onPressed: () {
                    if (widget.onAddStep != null )
                      setState(() {
                        widget.onAddStep!(RecipeStep(step: ''));
                      });
                  },
                )
              ]
            )
          )
        ],
      )
    );
  }
}
