import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../../widgets/core_widgets/my_icon_button.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/recipe_widgets/variant_bubble_widget.dart';

import '../../models/data_model.dart';

class RecipeVariantsWidget extends StatefulWidget {
  final String recipeId;
  final List<Variant> variants;
  final int userAccess;
  final Function()? onUpdate;
  RecipeVariantsWidget({Key? key, required this.recipeId, required this.variants, required this.userAccess, this.onUpdate}) : super(key: key);

  @override
  _RecipeVariantsWidgetState createState() => _RecipeVariantsWidgetState();
}

class _RecipeVariantsWidgetState extends State<RecipeVariantsWidget> {
  final TextEditingController _newVariantTextController = TextEditingController();
  bool widgetApertureState = false;

  @override
  Widget build(BuildContext context) {
    int variantLength = widgetApertureState || widget.variants.isEmpty ? widget.variants.length : 1;

    return Container(
      decoration: BoxDecoration(
        color: ThemeMgr.getTheme(context)!.cardColor.withOpacity(0.5),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
      ),
      // width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // generate variants
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Column(
                    children: List<Widget>.generate(variantLength, (index) {
                      int invertedIndex = widget.variants.length - 1 - index;
                      return VariantWidget(
                        variant: widget.variants[invertedIndex],

                        onRemove: () {
                          showAlertDialog(
                              context: context,
                              title: S.of(context).variant_remove_title,
                              description: Text(S.of(context).variant_remove_description)
                          ).then((value) {
                            if (value != null && value) {
                              // updateRecipe(
                              //   recipeId: widget.recipeId,
                              //   data: {
                              //     'variants': FieldValue.arrayRemove([widget.variants[invertedIndex].toJson()])
                              //   }
                              // ).then((value) {
                              //     if (widget.onUpdate != null)
                              //       widget.onUpdate!();
                              // });
                            }
                          });
                        },
                      );
                    })
                ),
                if (widget.userAccess > 0 && widgetApertureState)
                  MyTextField(
                    textEditingController: _newVariantTextController,
                    label: S.of(context).variant_widget_new,
                    suffixIcon: FontAwesomeIcons.paperPlane,
                    onSubmit: () async {
                      String? userId = DatabaseMgr().localMgr.getUserId();
                      if (userId != null)
                        print('test');
                        // await updateRecipe(
                        //   recipeId: widget.recipeId,
                        //   data: {
                        //     'variants': FieldValue.arrayUnion([Variant(variant: _newVariantTextController.text, userId: userId!).toJson()])
                        //   }
                        // ).then((value) {
                        //   _newVariantTextController.clear();
                        //   if (widget.onUpdate != null)
                        //     widget.onUpdate!();
                        // });
                    },
                  ),
                MyIconButton(
                  onPressed: () {
                    setState(() {
                      widgetApertureState = !widgetApertureState;
                    });
                  },
                  icon: widgetApertureState ? const Icon(Icons.keyboard_arrow_up_rounded) : const Icon(Icons.keyboard_arrow_down_rounded)
                )
              ],
            )
          )
        ],
      )
    );
  }
}
