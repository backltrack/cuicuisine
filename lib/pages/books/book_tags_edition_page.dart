import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../utilities/string_functions.dart';
import '../../widgets/core_widgets/alert_dialog.dart';
import '../../widgets/core_widgets/my_text_field.dart';

class BookTagsEditionPage extends StatefulWidget {
  const BookTagsEditionPage({super.key});

  @override
  State<BookTagsEditionPage> createState() => _BookTagsEditionPageState();
}

class _BookTagsEditionPageState extends State<BookTagsEditionPage> {
  late String _bookId;
  late List<Tag> _tags;
  bool _argsLoaded = false;

  List<dynamic> _buildListItems() {
    final Map<String, List<Tag>> byCategory = {};
    for (final tag in _tags) {
      (byCategory[tag.category] ??= []).add(tag);
    }
    final sortedCats = byCategory.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return removeDiacritics(a.toLowerCase()).compareTo(removeDiacritics(b.toLowerCase()));
      });
    final List<dynamic> items = [];
    for (final cat in sortedCats) {
      items.add(cat);
      final catTags = byCategory[cat]!
        ..sort((a, b) => removeDiacritics(a.name).compareTo(removeDiacritics(b.name)));
      items.addAll(catTags);
    }
    items.add(null);
    return items;
  }

  Widget _categoryHeader(String category) {
    final label = category.isEmpty ? S.of(context).tag_category_other : beautifyName(category);
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

  Future<void> _editTag(Tag tag) async {
    final nameCtrl = TextEditingController(text: tag.name);
    final categoryCtrl = TextEditingController(text: tag.category);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).new_tag_title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextField(
              textEditingController: nameCtrl,
              label: S.of(context).new_tag_name,
              icon: FontAwesomeIcons.hashtag,
              autofocus: true,
            ),
            MyTextField(
              textEditingController: categoryCtrl,
              label: S.of(context).new_tag_category,
              icon: FontAwesomeIcons.layerGroup,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context).ok),
          ),
        ],
      ),
    );
    if (confirmed == true && nameCtrl.text.trim().isNotEmpty) {
      await DatabaseMgr().localMgr.updateBookTag(
        _bookId,
        tag.id,
        name: nameCtrl.text.trim().toLowerCase(),
        category: categoryCtrl.text.trim().toLowerCase(),
      );
      setState(() {
        _tags = DatabaseMgr().localMgr.getBookTags().toList();
      });
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    final usageCount = DatabaseMgr().localMgr.countRecipesUsingTag(tag.id);

    bool? confirmed;
    if (usageCount == 0) {
      confirmed = await showAlertDialog(
        context: context,
        title: S.of(context).popup_delete_title,
        description: Text('${S.of(context).popup_delete_description_as_owner}"${tag.name}"?'),
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.of(context).popup_delete_title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.of(context).tag_delete_used_warning(usageCount, tag.name)),
              const SizedBox(height: 8),
              Text(S.of(context).tag_delete_used_confirm),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.of(context).remove_button,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    if (confirmed == true) {
      await DatabaseMgr().localMgr.deleteBookTag(_bookId, tag.id);
      if (mounted) {
        setState(() {
          _tags = DatabaseMgr().localMgr.getBookTags().toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_argsLoaded) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      _bookId = routeArgs['bookId']!;
      _tags = DatabaseMgr().localMgr.getBookTags().toList();
      _argsLoaded = true;
    }

    final listItems = _buildListItems();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_settings_tags),
      ),
      body: ListView.builder(
        itemCount: listItems.length,
        itemBuilder: (context, index) {
          final item = listItems[index];
          if (item == null) return const SizedBox(height: 24);
          if (item is String) return _categoryHeader(item);
          final tag = item as Tag;
          return ListTile(
            title: Text(tag.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.pen, size: 16),
                  onPressed: () => _editTag(tag),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.trash, size: 16),
                  onPressed: () => _deleteTag(tag),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
