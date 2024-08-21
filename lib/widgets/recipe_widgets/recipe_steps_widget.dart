import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/my_icon_button.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

import '../../models/data_model.dart';

class RecipeStepsWidget extends StatefulWidget {
  final List<RecipeStep> steps;
  RecipeStepsWidget({Key? key, required this.steps}) : super(key: key);

  @override
  _RecipeStepsWidgetState createState() => _RecipeStepsWidgetState();
}

class _RecipeStepsWidgetState extends State<RecipeStepsWidget> {
  double _textSize = 14;

  @override
  Widget build(BuildContext context) {
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
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: Center(
                  child:Text(
                    S.of(context).steps_widget_title,
                    style: ThemeMgr.getTheme(context)!.textTheme.displayMedium,
                  ),
                ),
              ),
              Positioned(
                top: -12,
                right: 0,
                child: Row(
                  children: [
                    MyIconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: () {
                        setState(() {
                          _textSize = _textSize > 12 ? _textSize - 2.0 : _textSize;
                        });
                      },
                    ),
                    MyIconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () {
                        setState(() {
                          _textSize = _textSize < 24 ? _textSize + 2.0 : _textSize;
                        });
                      },
                    )
                  ],
                )
              )
            ],
          ),

          const SizedBox(height: 12),
          // generate steps
          SizedBox(
            width: double.infinity,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(widget.steps.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                            "${S.of(context).steps_widget_step} ${index+1}",
                            style: ThemeMgr.getTheme(context)!.textTheme.displaySmall
                        ),
                        if (widget.steps[index].time > 0)
                          IconButton(
                            onPressed: () {
                              FlutterAlarmClock.createTimer(length: widget.steps[index].time * 60);
                            },
                            icon: const FaIcon(Icons.timer_outlined)
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Html(
                      data: widget.steps[index].step,
                      style: {
                        "*": Style(
                          fontSize: FontSize(_textSize)
                        )
                      }
                    ),

                    const SizedBox(height: 24)
                  ],
                );
              })
            )
          )
        ],
      )
    );
  }
}
