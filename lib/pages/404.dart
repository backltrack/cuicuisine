import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class PageNotFound extends StatelessWidget {
  static const String route = '/404';
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).page_not_found),
      ),
      body: const Center(
        child: Text(
          "404",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
