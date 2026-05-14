import 'package:cuicuisine/database/database_mgr.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../models/local_model.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';
import '../../widgets/core_widgets/my_type_ahead_text_field.dart';

class IngredientEditionPage extends StatefulWidget {

  const IngredientEditionPage({super.key});

  @override
  _IngredientEditionPageState createState() => _IngredientEditionPageState();
}

class _IngredientEditionPageState extends State<IngredientEditionPage> {
  Ingredient ingredient = Ingredient(bookIngredientId: '', quantity: 0);
  BookIngredient? selectedBookIngredient;
  bool _selectingFromSuggestion = false;

  late Unit unitMgr;
  DensityTable densityTable = DensityTable();

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController quantityTextEditingController = TextEditingController();
  TextEditingController densityTextEditingController = TextEditingController();

  bool shouldInit = true;
  bool expansionTileState = false;

  @override
  void initState() {
    super.initState();
    nameTextEditingController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (_selectingFromSuggestion) return;
    if (selectedBookIngredient != null) {
      setState(() { selectedBookIngredient = null; });
    }
    if (densityTextEditingController.text.isNotEmpty) {
      final double? currentDensity = double.tryParse(densityTextEditingController.text);
      if (currentDensity == 0) {
        final double found = densityTable.getDensity(nameTextEditingController.text.trim().toLowerCase());
        densityTextEditingController.text = found.toString();
        if (found != 0) {
          setState(() { expansionTileState = true; });
          ToastNotifier().showInfo(S.of(context).ingredient_density_updated);
        }
      }
    }
    if (nameTextEditingController.text.isEmpty) {
      densityTextEditingController.text = "0.0";
    }
  }

  void _linkBookIngredient(BookIngredient bi) {
    setState(() {
      selectedBookIngredient = bi;
      ingredient.bookIngredientId = bi.id;
      ingredient.unitOverride = null;
      ingredient.densityOverride = null;
    });
    densityTextEditingController.text = bi.density.toString();
  }

  Future<void> _createAndLinkBookIngredient() async {
    final String name = nameTextEditingController.text.trim();
    if (name.isEmpty) return;
    final String unit = ingredient.unitOverride ?? 'none';
    final double density = double.tryParse(densityTextEditingController.text) ?? 0.0;
    final String bookId = DatabaseMgr().localMgr.getCurrentBookId()!;
    final BookIngredient newBi = await DatabaseMgr().localMgr.addBookIngredient(bookId, name, unit, density);
    setState(() {
      selectedBookIngredient = newBi;
      ingredient.unitOverride = null;
      ingredient.densityOverride = null;
    });
  }

  void _resetOverrides() {
    setState(() {
      ingredient.unitOverride = null;
      ingredient.densityOverride = null;
    });
    if (selectedBookIngredient != null) {
      densityTextEditingController.text = selectedBookIngredient!.density.toString();
    }
  }

  @override
  void dispose() {
    nameTextEditingController.dispose();
    quantityTextEditingController.dispose();
    densityTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final bool isNew = routeArgs['isNew'];
    final String locale = routeArgs['locale'];
    if (!isNew) ingredient = routeArgs['ingredient']!;

    if (shouldInit) {
      if (!isNew) {
        selectedBookIngredient = DatabaseMgr().localMgr.getBookIngredient(ingredient.bookIngredientId);
      }
      // suppress listener during init to avoid setState-inside-build
      _selectingFromSuggestion = true;
      nameTextEditingController.text = ingredient.getName();
      quantityTextEditingController.text = (ingredient.quantity ?? 0).toString();
      densityTextEditingController.text = ingredient.getDensity().toString();
      _selectingFromSuggestion = false;
      setState(() { unitMgr = Unit(locale); });
      shouldInit = false;
    }

    final bool hasOverrides = (ingredient.unitOverride != null && ingredient.unitOverride!.isNotEmpty) ||
        (ingredient.densityOverride != null && ingredient.densityOverride != 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? S.of(context).new_ingredient_title : S.of(context).ingredient_edition_title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field + link indicator
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: MyTypeAheadTextField(
                    label: S.of(context).ingredient_name,
                    textEditingController: nameTextEditingController,
                    itemBuilder: (context, suggestion) {
                      if (suggestion == '__create__') {
                        return ListTile(
                          leading: const FaIcon(FontAwesomeIcons.plus, size: 14),
                          title: Text(S.of(context).ingredient_create_new_book_ingredient),
                        );
                      }
                      return ListTile(title: Text(beautifyName(suggestion)));
                    },
                    suggestionsCallback: (String pattern) {
                      if (pattern.isEmpty) return [];
                      final List<String> suggestions = [];
                      for (final BookIngredient bi in DatabaseMgr().localMgr.getBookIngredients()) {
                        if (removeDiacritics(bi.name).toLowerCase().contains(pattern.toLowerCase().trim())) {
                          suggestions.add(removeDiacritics(bi.name).toLowerCase().trim());
                        }
                      }
                      suggestions.sort();
                      suggestions.add('__create__');
                      return suggestions;
                    },
                    onSuggestionSelected: (String suggestion) {
                      if (suggestion == '__create__') {
                        _createAndLinkBookIngredient();
                        setState(() {});
                        return;
                      }
                      _selectingFromSuggestion = true;
                      nameTextEditingController.text = beautifyName(suggestion);
                      _selectingFromSuggestion = false;
                      try {
                        final BookIngredient bi = DatabaseMgr().localMgr.getBookIngredients().firstWhere(
                          (bi) => removeDiacritics(bi.name).toLowerCase().trim() == suggestion,
                        );
                        _linkBookIngredient(bi);
                        setState(() {});
                      } on StateError { /* no match */ }
                    },
                  ),
                ),
                if (selectedBookIngredient != null) ...[
                  FaIcon(FontAwesomeIcons.link, size: 16, color: ThemeMgr.getTheme(context)!.primaryColor),
                  IconButton(
                    tooltip: S.of(context).ingredient_edit_book_ingredient,
                    icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '${ModalRoute.of(context)!.settings.name!}/book_ingredient',
                        arguments: {
                          'bookIngredient': selectedBookIngredient!,
                          'bookId': DatabaseMgr().localMgr.getCurrentBookId()!,
                          'locale': locale,
                        },
                      );
                      if (result != null && result is BookIngredient) {
                        setState(() { selectedBookIngredient = result; });
                        _selectingFromSuggestion = true;
                        nameTextEditingController.text = result.name;
                        _selectingFromSuggestion = false;
                        if (ingredient.densityOverride == null) {
                          densityTextEditingController.text = result.density.toString();
                        }
                      }
                    },
                  ),
                ],
              ],
            ),

            // Quantity + unit picker
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: MyTextField(
                    textEditingController: quantityTextEditingController,
                    label: S.of(context).ingredient_quantity,
                    keyboardType: TextInputType.number,
                    suffixText: ingredient.getUnit() != 'none' ? ingredient.getUnit() : null,
                  ),
                ),
                PopupMenuButton(
                  icon: const FaIcon(FontAwesomeIcons.scaleBalanced, size: 20),
                  itemBuilder: (context) => List<PopupMenuItem>.generate(
                    unitMgr.getAllUnits().length,
                    (unitIndex) => PopupMenuItem(
                      child: Text(unitMgr.getAllUnits()[unitIndex], style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                      onTap: () {
                        setState(() {
                          ingredient.unitOverride = unitMgr.getAllUnits()[unitIndex];
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Reset overrides button (visible only when overrides are set)
            if (hasOverrides)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: TextButton.icon(
                  onPressed: _resetOverrides,
                  icon: const FaIcon(FontAwesomeIcons.arrowRotateLeft, size: 14),
                  label: Text(S.of(context).ingredient_reset_overrides),
                ),
              ),

            const Divider(),

            // Advanced section (density)
            Theme(
              data: ThemeMgr.getTheme(context)!.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: UniqueKey(),
                initiallyExpanded: expansionTileState,
                onExpansionChanged: (bool state) { expansionTileState = state; },
                title: Text(S.of(context).ingredient_advanced),
                collapsedTextColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                textColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                iconColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                collapsedIconColor: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: MyTextField(
                      textEditingController: densityTextEditingController,
                      label: S.of(context).ingredient_density,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).recipe_edition_update),
        onPressed: nameTextEditingController.text.isNotEmpty ? () async {
          if (selectedBookIngredient == null) {
            final String pattern = removeDiacritics(nameTextEditingController.text.trim()).toLowerCase();
            try {
              selectedBookIngredient = DatabaseMgr().localMgr.getBookIngredients().firstWhere(
                (bi) => removeDiacritics(bi.name).toLowerCase().trim() == pattern,
              );
            } on StateError {
              ToastNotifier().showError(S.of(context).ingredient_select_or_create);
              return;
            }
          }
          ingredient.bookIngredientId = selectedBookIngredient!.id;
          ingredient.quantity = double.tryParse(quantityTextEditingController.text.replaceAll(',', '.')) ?? 0;
          final double density = double.tryParse(densityTextEditingController.text) ?? 0;
          ingredient.densityOverride = density != selectedBookIngredient!.density ? density : null;
          Navigator.pop(context, ingredient);
        } : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
