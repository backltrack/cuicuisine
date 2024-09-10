import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/time_functions.dart';
import '../../widgets/recipe_widgets/widget_selection_overlay_widget.dart';

import '../../models/data_model.dart';
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
                ...List<Widget>.generate(newSteps.length, (index) {
                  return Column(
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
                            icon: FaIcon(FontAwesomeIcons.trashAlt, size: 18, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
                            color: ThemeMgr.getTheme(context)!.colorScheme.background,
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
                          child: Html(
                            data: newSteps[index].step.isNotEmpty ? newSteps[index].step : "step description",
                            onLinkTap: (String? url, Map<String, String> attributes, dom.Element? element) async {
                              print("url:$url");
                              if (url != null && url.isNotEmpty) {
                                
                                final Uri uri = Uri.parse(url);
                                await launchUrl(uri);
                              }
                            }
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
                          }).then((value) async {
                            if (value != null) {
                              print(value);
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
                    if (widget.onAddStep != null ) {
                      setState(() {
                        widget.onAddStep!(RecipeStep(step: ''));
                      });
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
