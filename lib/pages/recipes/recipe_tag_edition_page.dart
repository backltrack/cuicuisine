import 'package:cuicuisine/models/update_model.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../l10n/localeMgr.dart';
import '../../models/data_model.dart';
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

  List<Tag> _selectedTags = [];

  String locale = 'en';

  String _search = "";

  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();

    locale = LocaleMgr.getLocale(context);
    tags = computetags();
    setState(() {});
  }

  List<Tag> computetags() {
    final List<Tag> tags = [];
    for (Tag tag in DatabaseMgr().localMgr.getBookTags()) {
      if (! defaultTags[locale]!.contains(tag.name.trim().toLowerCase())) {
        tags.add(tag);
      }
    }
    tags.sort();
    return tags;
  }

  @override
  Widget build(BuildContext context) {

    // load params
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final List<Tag> currentTags = routeArgs['currentTags']!;
    final String recipeId = routeArgs['id']!;

    tags.sort((a, b) => removeDiacritics(a.name).compareTo(removeDiacritics(b.name)));

    if (shouldInitialize) {
      _selectedTags.clear();
      _selectedTags.addAll(currentTags);

      shouldInitialize = false;
    }

    ScrollController _scrollController = ScrollController();

    Widget listTile(Tag tag) {
      return ListTile(
        title: Text(tag.name),
        trailing: IconButton(
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
                FontAwesomeIcons.solidCircleCheck) : const FaIcon(
                FontAwesomeIcons.circlePlus)
        ),
      );
    }

    return Scaffold(
      appBar: SearchAppBar(
        myTitle: S.of(context).recipe_edition_tags_title,
        onSearchChanged: (String val) {
          setState(() {
            _search = val;
          });
        },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).recipe_edition_update),
        onPressed: () {
          DatabaseMgr().localMgr.updateRecipe(
            recipeId,
            RecipeUpdate(
              id: recipeId,
              tags: List.generate(_selectedTags.length, (index) => _selectedTags[index].id)
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
            onRemove: (Tag val) {
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
                if (!List.generate(tags.length, (index) => tags[index].name).contains(result.toString())) {
                  String? currentBookId = DatabaseMgr().localMgr.getCurrentBookId();
                  if (currentBookId != null) {
                    setState(() {
                      Tag newTag = Tag.newTag(result.toString(), '');
                      tags.add(newTag);

                      DatabaseMgr().localMgr.updateBook(currentBookId, 
                        BookUpdate(id: currentBookId, tags: tags)
                      );
                      tags = computetags();
                      
                      _selectedTags.add(newTag);
                    });
                  }
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
                itemCount: tags.length + 1,
                itemBuilder: (context, index) {
                  if (index == tags.length) {
                    // space for floating button
                    return const SizedBox(height: 80);
                  }
                  else {
                    return _search != "" && removeDiacritics(tags[index].name.toLowerCase()).contains(removeDiacritics(_search.toLowerCase())) || _search == "" ?
                    listTile(tags[index]) : const SizedBox();
                  }
                },
              )
          ),
        ],
      ),
    );
  }
}
