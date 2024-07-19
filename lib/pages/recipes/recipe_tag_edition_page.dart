import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../l10n/localeMgr.dart';
import '../../pages/home_page.dart';
import '../../widgets/core_widgets/my_icon_button.dart';
import '../../widgets/core_widgets/my_outlined_button.dart';
import '../../widgets/recipe_widgets/recipe_tags_widget.dart';
import '../../widgets/core_widgets/search_app_bar.dart';

import '../../models/default_data.dart';
import '../../widgets/core_widgets/alert_dialog.dart';

class RecipeTagEditionPage extends StatefulWidget {
  const RecipeTagEditionPage();

  @override
  _RecipeTagEditionPageState createState() => _RecipeTagEditionPageState();
}

class _RecipeTagEditionPageState extends State<RecipeTagEditionPage> {
  bool shouldInitialize = true;

  List<String> _selectedTags = [];

  String locale = 'en';

  String _search = "";

  List<String> customTags = [];

  @override
  void initState() {
    super.initState();

    locale = LocaleMgr.getLocale(context);
    customTags = computeCustomTags();
    setState(() {});
  }

  List<String> computeCustomTags() {
    final List<String> customTags = [];
    for (String tag in DatabaseMgr().localMgr.getBookTags()) {
      if (! defaultTags[locale]!.contains(tag.trim().toLowerCase())) {
        customTags.add(tag);
      }
    }
    customTags.sort();
    return customTags;
  }

  @override
  Widget build(BuildContext context) {

    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final List<String> currentTags = routeArgs['currentTags']!;
    final String recipeId = routeArgs['id']!;

    if (shouldInitialize) {
      _selectedTags.clear();
      _selectedTags.addAll(currentTags);

      shouldInitialize = false;
    }

    ScrollController _scrollController = ScrollController();

    Widget listTile(tag) {
      return ListTile(
        title: Text(tag),
        trailing: MyIconButton(
            onPressed: () {
              if (_selectedTags.contains(tag)) {
                setState(() {
                  _selectedTags.remove(tag);
                });
              } else {
                setState(() {
                  _selectedTags.add(tag);
                });
              }
            },
            icon: _selectedTags.contains(tag) ? const FaIcon(
                FontAwesomeIcons.solidCheckCircle) : const FaIcon(
                FontAwesomeIcons.plusCircle)
        ),
      );
    }

    return WillPopScope(
      child: Scaffold(
        appBar: SearchAppBar(
          myTitle: S.of(context).recipe_edition_tags_title,
          onSearchChanged: (String val) {
            setState(() {
              _search = val;
            });
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          label: Text(S.of(context).recipe_edition_update),
          onPressed: () {
            DatabaseMgr().localMgr.updateRecipe(
              recipeId,
              RecipeUpdate(
                id: recipeId,
                tags: _selectedTags
              )
            );

            Navigator.pop(context, 'update');
          },
        ),
        body: Column(
          children: [
            RecipeTagsWidget(
              tags: _selectedTags,
              isEditable: true,
              onRemove: (String val) {
                setState(() {
                  _selectedTags.remove(val);
                });
              },
            ),

            const SizedBox(
              height: 12,
            ),
            MyOutlinedButton(
              text: S.of(context).add_button,
              icon: FontAwesomeIcons.plus,
              onPressed: () async {
                var result = await Navigator.pushNamed(context, '${ModalRoute.of(context)!.settings.name!}/new');
                if (result != null) {
                  if (!customTags.contains(result.toString())) {
                    setState(() {
                      customTags.add(result.toString());
                      _selectedTags.add(result.toString());
                    });
                  }
                }
              },
            ),
            const SizedBox(
              height: 12,
            ),

            Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: defaultTags[locale]!.length + customTags.length + 2,
                  itemBuilder: (context, index) {
                    if (index == defaultTags[locale]!.length + customTags.length + 1) {
                      return const SizedBox(height: 80);
                    } 
                    else if (index == customTags.length) {
                      return customTags.isNotEmpty ? const Divider() : const SizedBox();
                    }
                    else if (index < customTags.length) {
                      return _search != "" && customTags[index].contains(_search) || _search == "" ?
                      listTile(customTags[index]) : const SizedBox();
                    }
                    else {
                      return _search != "" && defaultTags[locale]![index-customTags.length-1].contains(_search) || _search == "" ?
                      listTile(defaultTags[locale]![index-customTags.length-1]) : const SizedBox();
                    }
                  },
                )
            ),
          ],
        ),
      ),
      onWillPop: () async {
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
        return returnValue;
      });
  }
}
