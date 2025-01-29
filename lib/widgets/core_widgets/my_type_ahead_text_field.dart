import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../themes/theme_mgr.dart';

class MyTypeAheadTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Function? onSubmit;
  final TextEditingController? textEditingController;
  final bool autofocus;
  final TextInputType keyboardType;
  final Widget Function(BuildContext, dynamic) itemBuilder;
  final FutureOr<List<String>> Function(String) suggestionsCallback;
  final Function(String) onSuggestionSelected;
  final TextCapitalization textCapitalization;

  const MyTypeAheadTextField({
    super.key,
    required this.label,
    required this.itemBuilder,
    required this.suggestionsCallback,
    required this.onSuggestionSelected,
    this.icon,
    this.onSubmit,
    this.textEditingController,
    this.autofocus=false,
    this.keyboardType=TextInputType.name,
    this.textCapitalization=TextCapitalization.words
  });

  @override
  _MyTypeAheadTextFieldState createState() => _MyTypeAheadTextFieldState();
}

class _MyTypeAheadTextFieldState extends State<MyTypeAheadTextField> {
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var outlineInputBorder = OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
            color: ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color!,
            width: 2
        )
    );

    return Container(
      padding: const EdgeInsets.all(8),
      child: TypeAheadField(
        controller: widget.textEditingController,
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              border: outlineInputBorder
            ),
            textCapitalization: widget.textCapitalization,
            keyboardType: widget.keyboardType
          );
        },
        itemBuilder: widget.itemBuilder,
        onSelected: widget.onSuggestionSelected,
        suggestionsCallback: widget.suggestionsCallback
      )
    );
  }
}


// ,TypeAheadField(
//         textFieldConfiguration: TextFieldConfiguration(
//           keyboardType: widget.keyboardType,
//           controller: widget.textEditingController,
//           focusNode: _focusNode,
//           autofocus: widget.autofocus,
//           decoration: InputDecoration(
//             labelText: widget.label,
//             labelStyle: isFocused ? ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: ThemeMgr.getTheme(context)!.primaryColor) : ThemeMgr.getTheme(context)!.textTheme.bodyLarge,
//             prefixIcon: widget.icon != null ? (Icon(widget.icon, color: isFocused ? ThemeMgr.getTheme(context)!.primaryColor : ThemeMgr.getTheme(context)!.textTheme.bodyText2!.color)) : null,
//             focusedBorder: OutlineInputBorder(
//                 borderRadius: const BorderRadius.all(Radius.circular(12)),
//                 borderSide: BorderSide(
//                     color: ThemeMgr.getTheme(context)!.primaryColor,
//                     width: 2
//                 )
//             ),
//             border: outlineInputBorder,
//             enabledBorder: outlineInputBorder,
//           ),
//           style: ThemeMgr.getTheme(context)!.textTheme.headline2
//         ),
//         hideOnEmpty: true,

//         itemBuilder: widget.itemBuilder,
//         suggestionsCallback: widget.suggestionsCallback,
//         onSuggestionSelected: widget.onSuggestionSelected,
//       ),
