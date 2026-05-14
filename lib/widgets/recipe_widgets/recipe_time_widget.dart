import 'package:flutter/material.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/time_functions.dart';
import '../../generated/l10n.dart';

class RecipeTimeWidget extends StatelessWidget {
  final int preparationTime;
  final int waitingTime;
  final int cookingTime;

  const RecipeTimeWidget({super.key, required this.preparationTime, required this.waitingTime, required this.cookingTime});

  @override
  Widget build(BuildContext context) {
    final int totalTime = preparationTime + waitingTime + cookingTime;

    return Container(
      decoration: BoxDecoration(
        color: ThemeMgr.getTheme(context)!.cardColor,
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 8, top: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Column(
              children: [
                Text(
                    S.of(context).time_widget_text,
                    style: ThemeMgr.getTheme(context)!.textTheme.displayMedium
                ),
                SizedBox(height: 4),
                Text(
                    minutesToTime(totalTime),
                    style: ThemeMgr.getTheme(context)!.textTheme.displayLarge
                )
              ],
            ),
          ),

          Container(
            height: 50,
            child: VerticalDivider(
              color: ThemeMgr.getTheme(context)!.colorScheme.surface,
              thickness: 2,
              width: 12,
            ),
          ),

          Container(
            //width: double.infinity,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).time_widget_preparation),
                      Text(S.of(context).time_widget_waiting),
                      Text(S.of(context).time_widget_cooking),
                    ],
                  ),
                  SizedBox(
                    width: 48,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(minutesToTime(preparationTime)),
                      Text(minutesToTime(waitingTime)),
                      Text(minutesToTime(cookingTime)),
                    ],
                  )
                ],
              )
          )
        ],
      ),
    );
  }
}
