import 'package:flutter/material.dart';
import '../../themes/theme_mgr.dart';

Future<void> showImagePopup({required context, required Image image}) async {
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: image,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                color: ThemeMgr.getTheme(context)!.iconTheme.color,
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        )
      );
    }
  );
}
