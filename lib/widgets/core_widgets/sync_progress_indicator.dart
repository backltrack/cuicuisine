import 'package:flutter/material.dart';

import '../../database/database_mgr.dart';
import '../../themes/theme_mgr.dart';

// App icon avatar with a circular progress ring that fills according to
// DatabaseMgr().syncProgress while a synchronization is in progress.
class SyncProgressIndicator extends StatefulWidget {
  const SyncProgressIndicator({super.key});

  @override
  State<SyncProgressIndicator> createState() => _SyncProgressIndicatorState();
}

class _SyncProgressIndicatorState extends State<SyncProgressIndicator> {
  @override
  void initState() {
    super.initState();
    DatabaseMgr().addListener(_onChanged);
  }

  @override
  void dispose() {
    DatabaseMgr().removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double? progress = DatabaseMgr().syncProgress;
    const double avatarRadius = 128 / 2 + 36;
    const double strokeWidth = 4.0;
    const double boxSize = (avatarRadius + strokeWidth / 2) * 2;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.surface,
            child: Image.asset('assets/icons/splash_icon.png', width: 128),
          ),
          if (progress != null)
            SizedBox(
              width: boxSize,
              height: boxSize,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                color: ThemeMgr.getTheme(context)!.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
