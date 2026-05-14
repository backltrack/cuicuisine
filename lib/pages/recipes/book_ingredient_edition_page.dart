import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../models/local_model.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/toast_notifier.dart';
import '../../widgets/core_widgets/my_text_field.dart';

class BookIngredientEditionPage extends StatefulWidget {
  const BookIngredientEditionPage({super.key});

  @override
  _BookIngredientEditionPageState createState() => _BookIngredientEditionPageState();
}

class _BookIngredientEditionPageState extends State<BookIngredientEditionPage> {
  late String _bookId;
  late String _bookIngredientId;
  String _unit = 'none';

  late Unit unitMgr;

  TextEditingController nameController = TextEditingController();
  TextEditingController densityController = TextEditingController();

  bool shouldInit = true;

  @override
  void dispose() {
    nameController.dispose();
    densityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final BookIngredient bookIngredient = routeArgs['bookIngredient'] as BookIngredient;
    final String locale = routeArgs['locale'] as String;

    if (shouldInit) {
      _bookId = routeArgs['bookId'] as String;
      _bookIngredientId = bookIngredient.id;
      _unit = bookIngredient.unit;
      nameController.text = bookIngredient.name;
      densityController.text = bookIngredient.density.toString();
      setState(() { unitMgr = Unit(locale); });
      shouldInit = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_ingredient_edition_title),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            MyTextField(
              textEditingController: nameController,
              label: S.of(context).ingredient_name,
              keyboardType: TextInputType.name,
              autofocus: true,
            ),

            // Unit
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: S.of(context).ingredient_unit,
                        labelStyle: ThemeMgr.getTheme(context)!.textTheme.bodyLarge,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color!,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color!,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(_unit, style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const FaIcon(FontAwesomeIcons.scaleBalanced, size: 20),
                  itemBuilder: (context) => List<PopupMenuItem>.generate(
                    unitMgr.getAllUnits().length,
                    (i) => PopupMenuItem(
                      child: Text(unitMgr.getAllUnits()[i], style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge),
                      onTap: () {
                        setState(() { _unit = unitMgr.getAllUnits()[i]; });
                      },
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            // Density
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: MyTextField(
                textEditingController: densityController,
                label: S.of(context).ingredient_density,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(S.of(context).recipe_edition_update),
        onPressed: nameController.text.isNotEmpty ? () async {
          final String name = nameController.text.trim();
          if (name.isEmpty) {
            ToastNotifier().showError(S.of(context).error_name_empty);
            return;
          }
          final double density = double.tryParse(densityController.text) ?? 0.0;
          await DatabaseMgr().localMgr.updateBookIngredient(
            _bookId,
            _bookIngredientId,
            name: name,
            unit: _unit,
            density: density,
          );
          if (!mounted) return;
          Navigator.pop(this.context, BookIngredient(
            id: _bookIngredientId,
            name: name,
            unit: _unit,
            density: density,
          ));
        } : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
