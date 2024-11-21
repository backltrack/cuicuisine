import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../themes/theme_mgr.dart';

class MyTextField extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Function? onChanged;
  final Function? onSubmit;
  final Function? onTap;
  final TextEditingController? textEditingController;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final String? suffixText;
  final IconData? suffixIcon;
  final bool isPassword;
  final int? maxLength;
  final Color? overrideTextColor;

  const MyTextField({
    Key? key,
    required this.label,
    this.icon,
    this.onChanged,
    this.onSubmit,
    this.onTap,
    this.textEditingController,
    this.autofocus=false,
    this.focusNode,
    this.keyboardType=TextInputType.name,
    this.suffixText,
    this.suffixIcon,
    this.isPassword=false,
    this.maxLength,
    this.overrideTextColor
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late FocusNode _focusNode;
  bool isFocused = false;

  bool isObscured = false;

  @override
  void initState() {
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    }
    else {
      _focusNode = FocusNode();
    }

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    isObscured = widget.isPassword;

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
      child: TextField(
        inputFormatters: [
          if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength)
        ],
        keyboardType: widget.keyboardType,
        controller: widget.textEditingController,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        obscureText: isObscured,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: isFocused ? ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.copyWith(color: ThemeMgr.getTheme(context)!.primaryColor) : ThemeMgr.getTheme(context)!.textTheme.bodyLarge,
          prefixIcon: widget.icon != null ? (Icon(widget.icon, color: isFocused ? ThemeMgr.getTheme(context)!.primaryColor : ThemeMgr.getTheme(context)!.textTheme.bodyText2!.color, size: 20)) : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: ThemeMgr.getTheme(context)!.primaryColor,
              width: 2
            )
          ),
          suffixText: widget.suffixText,
          suffixStyle: ThemeMgr.getTheme(context)!.textTheme.headline2,
          suffixIcon: widget.isPassword ? IconButton(
            padding: EdgeInsets.zero,
            icon: FaIcon(isObscured ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash, color: Colors.grey, size: 20),
            onPressed: () {
              setState(() {
                isObscured = !isObscured;
              });
            },
          ) : widget.suffixIcon != null ?
            IconButton(
              onPressed: () {
                if (widget.onSubmit != null) widget.onSubmit!();
              },
              icon: Icon(widget.suffixIcon!, color: ThemeMgr.getTheme(context)!.textTheme.bodyText2!.color, size: 20)
            )
            : null,
          border: outlineInputBorder,
          enabledBorder: outlineInputBorder,
        ),
        style: widget.overrideTextColor != null ? ThemeMgr.getTheme(context)!.textTheme.headline2!.copyWith(color: widget.overrideTextColor) : ThemeMgr.getTheme(context)!.textTheme.headline2,
        onChanged: (String val) {
          if (widget.onChanged != null) widget.onChanged!(val);
        },
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
          else if (widget.keyboardType == TextInputType.number) {
            if (widget.textEditingController != null) {
                widget.textEditingController!.selection = TextSelection(baseOffset: 0, extentOffset: widget.textEditingController!.text.length);
              }
            }
        }
      ),
    );
  }
}
