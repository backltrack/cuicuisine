import 'dart:convert';

import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderables/reorderables.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/time_functions.dart';
import '../../widgets/recipe_widgets/widget_selection_overlay_widget.dart';

import '../../models/data_model.dart';
import '../core_widgets/circular_button.dart';
import '../core_widgets/my_outlined_button.dart';
import '../../utilities/logger.dart';

final _log = Logger('RecipeStepsEditionWidget');

class RecipeStepsEditionWidget extends StatefulWidget {
  final List<RecipeStep> steps;
  final Function(Map<String, dynamic>)? onStepChanged;
  final Function(RecipeStep)? onAddStep;
  final Function(int)? onRemoveStep;
  final Function(int, int)? onReorderSteps;
  const RecipeStepsEditionWidget({super.key, required this.steps, this.onStepChanged, this.onAddStep, this.onRemoveStep, this.onReorderSteps});

  @override
  _RecipeStepsEditionWidgetState createState() => _RecipeStepsEditionWidgetState();
}

class _RecipeStepsEditionWidgetState extends State<RecipeStepsEditionWidget> {
  List<RecipeStep> newSteps = [];
  bool isInit = false;

  final List<QuillController> controllers = [];

  @override
  void dispose() {
    for (QuillController controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!isInit) {
      newSteps.addAll(widget.steps);
      isInit = true;
    }

    for (QuillController controller in controllers) {
      controller.dispose();
    }
    controllers.clear();
    for (var step in widget.steps) {
      controllers.add(QuillController(
        document: step.step.isNotEmpty ? Document.fromJson(jsonDecode(step.step)) : Document(),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true
      ));
    }

    return Container(
      decoration: BoxDecoration(
        color: ThemeMgr.getTheme(context)!.cardColor,
        borderRadius: BorderRadius.circular(12)
      ),
      // width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
      child: Column(
        children: [
          // title and zoom buttons
          SizedBox(
            width: double.infinity,
            child: Center(
              child:Text(
                S.of(context).steps_widget_title,
                style: ThemeMgr.getTheme(context)!.textTheme.displayMedium,
              ),
            ),
          ),

          const SizedBox(height: 12),
          // generate steps
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableColumn(
                  children: [
                    ...List<Widget>.generate(newSteps.length, (index) {
                      return Column(
                        key: UniqueKey(),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "${S.of(context).steps_widget_step} ${index+1}",
                                  style: ThemeMgr.getTheme(context)!.textTheme.displaySmall
                              ),
                              CircularIconButton(
                                icon: FaIcon(FontAwesomeIcons.trashCan, size: 18, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
                                color: ThemeMgr.getTheme(context)!.colorScheme.surface,
                                onPressed: () {
                                  if (widget.onRemoveStep != null) {
                                    widget.onRemoveStep!(index);
                                  }
                                },
                              )
                            ],
                          ),

                          const SizedBox(height: 4),

                          WidgetSelectionOverlay(
                            widget: Container(
                              constraints: const BoxConstraints(
                                  minHeight: 56
                              ),
                              child: QuillEditor.basic(
                                controller: controllers[index],
                                config: QuillEditorConfig(
                                  expands: false,
                                  scrollable: false,
                                  padding: EdgeInsetsGeometry.all(4.0),
                                  customStyles: DefaultStyles(
                                    link: DefaultStyles.getInstance(context).link!.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue
                                    )
                                  )
                                ),
                              )
                            ),
                            borderRadius: 2,
                            margin: 2,
                            editModeController: true,
                            opacity: ThemeMgr.isDarkTheme(context) ? 0.9 : 0.6,
                            onTap: () {
                              Navigator.pushNamed(context, "${ModalRoute.of(context)!.settings.name!}/$index", arguments: {
                                "stepNumber": index,
                                "stepDescription": newSteps[index].step
                              }).then((value) {
                                _log.fine("step updated: $value");
                                if (value != null) {
                                  if (widget.onStepChanged != null) {
                                    widget.onStepChanged!({
                                      'step': value.toString(),
                                      'index': index
                                    });
                                  }
                                }
                              });
                            },
                          ),

                          const SizedBox(height: 8),

                          InkWell(
                            onTap: () async {
                              var resultingDuration = await showDurationPicker(
                                context: context,
                                initialTime: Duration(minutes: newSteps[index].time),
                                // snapToMins: 5.0,
                              );
                              if (resultingDuration != null)
                              {
                                newSteps[index].time = resultingDuration.inMinutes;
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
                    })
                  ],
                  onReorder: (int oldIndex, int newIndex) {
                    if (widget.onReorderSteps != null) {
                      widget.onReorderSteps!(oldIndex, newIndex);
                    }
                  },
                ),

                // Last item: Add Button
                MyOutlinedButton(
                  text: S.of(context).add_button,
                  icon: FontAwesomeIcons.plus,
                  onPressed: () {
                    if (widget.onAddStep != null ) {
                      widget.onAddStep!(RecipeStep(step: ''));
                    }
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
