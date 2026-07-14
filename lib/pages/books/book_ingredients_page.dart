import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';

class BookIngredientsPage extends StatefulWidget {
  const BookIngredientsPage({super.key});

  @override
  State<BookIngredientsPage> createState() => _BookIngredientsPageState();
}

class _BookIngredientsPageState extends State<BookIngredientsPage> {
  late String _bookId;
  bool _shouldInit = true;

  bool _mergeMode = false;
  final Set<String> _selected = {};

  List<BookIngredient> _getSorted() {
    final list = List<BookIngredient>.from(DatabaseMgr().localMgr.getBookIngredients());
    list.sort((a, b) =>
        removeDiacritics(a.name.toLowerCase()).compareTo(removeDiacritics(b.name.toLowerCase())));
    return list;
  }

  Future<void> _editIngredient(BookIngredient bi) async {
    final locale = Localizations.localeOf(context).languageCode;
    final result = await Navigator.pushNamed(
      context,
      '${ModalRoute.of(context)!.settings.name!}/book_ingredient',
      arguments: {
        'bookIngredient': bi,
        'bookId': _bookId,
        'locale': locale,
      },
    );
    if (result != null && result is BookIngredient) {
      setState(() {});
    }
  }

  Future<void> _startMerge() async {
    final ingredients = DatabaseMgr()
        .localMgr
        .getBookIngredients()
        .where((bi) => _selected.contains(bi.id))
        .toList()
      ..sort((a, b) => removeDiacritics(a.name.toLowerCase())
          .compareTo(removeDiacritics(b.name.toLowerCase())));

    final BookIngredient? toKeep = await showDialog<BookIngredient>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(S.of(ctx).book_ingredients_merge_keep),
        children: ingredients
            .map((bi) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, bi),
                  child: Text(beautifyName(bi.name),
                      style: ThemeMgr.getTheme(ctx)!.textTheme.bodyLarge),
                ))
            .toList(),
      ),
    );
    if (toKeep == null || !mounted) return;

    await DatabaseMgr().localMgr.mergeBookIngredients(
      _bookId,
      _selected.toList(),
      toKeep.id,
    );

    setState(() {
      _mergeMode = false;
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    if (_shouldInit) {
      _bookId = routeArgs['bookId'] as String;
      _shouldInit = false;
    }

    final List<BookIngredient> ingredients = _getSorted();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_ingredients_title),
        actions: [
          IconButton(
            icon: FaIcon(
              _mergeMode ? FontAwesomeIcons.xmark : FontAwesomeIcons.codeMerge,
            ),
            tooltip: _mergeMode
                ? S.of(context).cancel
                : S.of(context).book_ingredients_merge_mode,
            onPressed: () {
              setState(() {
                _mergeMode = !_mergeMode;
                _selected.clear();
              });
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _mergeMode && _selected.length >= 2
          ? FloatingActionButton.extended(
              label: Text(S.of(context).book_ingredients_merge),
              icon: const FaIcon(FontAwesomeIcons.codeMerge),
              onPressed: _startMerge,
            )
          : null,
      body: ingredients.isEmpty
          ? Center(child: Text(S.of(context).book_ingredients_empty))
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: ingredients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final bi = ingredients[index];
                final bool selected = _selected.contains(bi.id);
                final bool hasUnit = bi.unit.isNotEmpty && bi.unit != 'none';
                final Widget? unitBadge = hasUnit
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ThemeMgr.getTheme(context)!.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bi.unit,
                          style: ThemeMgr.getTheme(context)!.textTheme.bodySmall,
                        ),
                      )
                    : null;
                return ListTile(
                  leading: _mergeMode
                      ? Checkbox(
                          value: selected,
                          onChanged: (_) => setState(() {
                            selected ? _selected.remove(bi.id) : _selected.add(bi.id);
                          }),
                        )
                      : null,
                  title: Text(beautifyName(bi.name)),
                  onTap: _mergeMode
                      ? () => setState(() {
                            selected ? _selected.remove(bi.id) : _selected.add(bi.id);
                          })
                      : null,
                  trailing: _mergeMode
                      ? unitBadge
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (unitBadge != null) ...[
                              unitBadge,
                              const SizedBox(width: 4),
                            ],
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.pen, size: 16),
                              onPressed: () => _editIngredient(bi),
                            ),
                          ],
                        ),
                );
              },
            ),
    );
  }
}
