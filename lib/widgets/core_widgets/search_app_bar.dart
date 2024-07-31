import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../themes/colors.dart';
import '../../themes/theme_mgr.dart';
import 'animated_search_bar.dart';

class SearchAppBar extends AppBar {
  static bool isSearching = false;

  final String? myTitle;
  final Function(String) onSearchChanged;
  final Widget? leading;

  SearchAppBar({Key? key, this.myTitle, required this.onSearchChanged, this.leading}) : super(key: key);

  @override
  _SearchAppBarState createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {

  TextEditingController _searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
    final bool hasDrawer = scaffold?.hasDrawer ?? false;

    return AppBar(
      title: widget.myTitle != null ? Text(widget.myTitle!) : null,
      leading: hasDrawer ? Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.menu, size: 26),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }
      ) : widget.leading,
      actions: [
        Container(
          padding: EdgeInsets.only(right: 5),
          child: AnimSearchBar(
            width: MediaQuery.of(context).size.width * 3 / 5,
            textController: _searchTextController,
            color: Colors.black87,
            style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: DarkColors.writingColor),
            closeSearchOnSuffixTap: true,
            autoFocus: true,
            onSearchChanged: (String val) => widget.onSearchChanged(_searchTextController.text),
            onSuffixTap: () {
              setState(() {
                _searchTextController.clear();
                widget.onSearchChanged(_searchTextController.text);
              });
            },
            helpText: S.of(context).search,
          ),
        )
      ]
    );
  }
}
