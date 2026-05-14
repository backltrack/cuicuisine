import 'package:cuicuisine/models/update_model.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../generated/l10n.dart';
import '../../database/database_mgr.dart';
import '../../models/data_model.dart';
import '../../widgets/core_widgets/my_outlined_button.dart';
import '../../widgets/recipe_widgets/recipe_tags_widget.dart';
import '../../widgets/core_widgets/search_app_bar.dart';

import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/alert_dialog.dart';

class RecipeTagEditionPage extends StatefulWidget {
  const RecipeTagEditionPage({super.key});

  @override
  _RecipeTagEditionPageState createState() => _RecipeTagEditionPageState();
}

class _RecipeTagEditionPageState extends State<RecipeTagEditionPage> {
  bool shouldInitialize = true;

  List<Tag> _selectedTags = [];

  String _search = "";

  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();

    tags = _computeTags();
    setState(() {});
  }

  List<Tag> _computeTags() {
    return DatabaseMgr().localMgr.getBookTags().toList();
  }

  /// Builds a flat list of items for the ListView: alternating String headers
  /// and Tag items, followed by a null sentinel for the bottom spacer.
  List<dynamic> _buildListItems(List<Tag> filtered) {
    final Map<String, List<Tag>> byCategory = {};
    for (final tag in filtered) {
      (byCategory[tag.category] ??= []).add(tag);
    }

    // Sort categories: non-empty alphabetically first, empty category last
    final sortedCats = byCategory.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return removeDiacritics(a.toLowerCase()).compareTo(removeDiacritics(b.toLowerCase()));
      });

    final List<dynamic> items = [];
    for (final cat in sortedCats) {
      items.add(cat); // category header (String)
      final catTags = byCategory[cat]!
        ..sort((a, b) => removeDiacritics(a.name).compareTo(removeDiacritics(b.name)));
      items.addAll(catTags);
    }
    items.add(null); // bottom spacer sentinel
    return items;
  }

  Widget _categoryHeader(String category) {
    final label = category.isEmpty
        ? S.of(context).tag_category_other
        : beautifyName(category);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(label, style: ThemeMgr.getTheme(context)!.textTheme.displayMedium),
          const SizedBox(width: 8),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _tagTile(Tag tag) {
    final bool selected = _selectedTags.contains(tag);
    return ListTile(
      title: Text(tag.name),
      trailing: IconButton(
        onPressed: () {
          setState(() {
            selected ? _selectedTags.remove(tag) : _selectedTags.add(tag);
          });
        },
        icon: selected
            ? const FaIcon(FontAwesomeIcons.solidCircleCheck)
            : const FaIcon(FontAwesomeIcons.circlePlus),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final List<Tag> currentTags = routeArgs['currentTags']!;
    final String recipeId = routeArgs['id']!;

    if (shouldInitialize) {
      _selectedTags.clear();
      _selectedTags.addAll(currentTags);
      shouldInitialize = false;
    }

    final List<Tag> filtered = _search.isEmpty
        ? tags
        : tags.where((t) => removeDiacritics(t.name.toLowerCase())
            .contains(removeDiacritics(_search.toLowerCase()))).toList();

    final List<dynamic> listItems = _buildListItems(filtered);

    return Scaffold(
      appBar: SearchAppBar(
        myTitle: S.of(context).recipe_edition_tags_title,
        onSearchChanged: (String val) {
          setState(() { _search = val; });
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
                  Text(S.of(context).recipe_edition_update, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(S.of(context).popup_loose_data_2, textAlign: TextAlign.center),
                  Text(S.of(context).popup_loose_data_3, textAlign: TextAlign.center),
                ],
              ),
            ).then((value) {
              if (value != null && value) returnValue = true;
            });

            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop(returnValue);
            });
          },
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
              tags: List.generate(_selectedTags.length, (i) => _selectedTags[i].id),
            ),
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
              setState(() { _selectedTags.remove(val); });
            },
          ),

          const SizedBox(height: 12),

          MyOutlinedButton(
            text: S.of(context).add_button,
            icon: FontAwesomeIcons.plus,
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '${ModalRoute.of(context)!.settings.name!}/new',
              );
              if (result != null && result is Map) {
                final String name = result['name'] as String;
                final String category = result['category'] as String? ?? '';
                if (!tags.any((t) => t.name == name)) {
                  final String? currentBookId = DatabaseMgr().localMgr.getCurrentBookId();
                  if (currentBookId != null) {
                    setState(() {
                      final Tag newTag = Tag.newTag(name, category);
                      final selectedIds = _selectedTags.map((t) => t.id).toSet()..add(newTag.id);
                      tags.add(newTag);
                      DatabaseMgr().localMgr.updateBook(
                        currentBookId,
                        BookUpdate(id: currentBookId, tags: tags),
                      );
                      tags = _computeTags();
                      _selectedTags = tags.where((t) => selectedIds.contains(t.id)).toList();
                    });
                  }
                }
              }
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              itemCount: listItems.length,
              itemBuilder: (context, index) {
                final item = listItems[index];
                if (item == null) return const SizedBox(height: 80);
                if (item is String) return _categoryHeader(item);
                return _tagTile(item as Tag);
              },
            ),
          ),
        ],
      ),
    );
  }
}
