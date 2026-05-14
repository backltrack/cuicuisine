import 'package:cuicuisine/database/database_mgr.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../generated/l10n.dart';

class SynchronizationStatusPage extends StatefulWidget {
  static const String route = '/synchronization_status';

  const SynchronizationStatusPage({super.key});

  @override
  State<SynchronizationStatusPage> createState() =>
      _SynchronizationStatusPageState();
}

class _SynchronizationStatusPageState extends State<SynchronizationStatusPage> {
  bool isOnline = false;
  bool isCountValid = false;
  bool isUpToDate = false;
  int queueLength = 0;
  int getNewerChangesCount= 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isOnline = await DatabaseMgr().remoteMgr.testConnexion();
    queueLength = DatabaseMgr().localMgr.getQueueLength();
    if (isOnline) {
      String? lastChange = DatabaseMgr().localMgr.getLastChange();
      if (lastChange != null) {
        int? _count = await DatabaseMgr().remoteMgr.getNewerChangesCount(lastChange);
        isCountValid = _count != null;
        if (isCountValid) {
          getNewerChangesCount = _count!;
        }
      }
    }
    isUpToDate = isOnline && isCountValid && queueLength == 0 && getNewerChangesCount == 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).synchronization_status_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: Row(children: [
              Text(S.of(context).synchronization_status, style: Theme.of(context).textTheme.displayMedium),
              const Spacer(),
              if (isUpToDate) 
                Text(S.of(context).synchronization_status_up_to_date, style: Theme.of(context).textTheme.bodyLarge)
              else if (!isUpToDate && !isOnline) 
                Text(S.of(context).offline_alert_title, style: Theme.of(context).textTheme.bodyLarge)
              else if (!isUpToDate && isOnline && isCountValid)
                Text(S.of(context).synchronization_status_need_sync, style: Theme.of(context).textTheme.bodyLarge)
              else if (!isUpToDate && isOnline && !isCountValid)
                Text(S.of(context).synchronization_status_failure, style: Theme.of(context).textTheme.bodyLarge)
              ]
            ),
          ),
          ListTile(
             title: Text(S.of(context).synchronization_queue, style: Theme.of(context).textTheme.displayMedium),
             trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(queueLength.toString(), style: Theme.of(context).textTheme.displaySmall),
                Icon(FontAwesomeIcons.arrowUp, size: 16, color: Theme.of(context).textTheme.displaySmall!.color),
                const SizedBox(width: 16),
                Text(getNewerChangesCount.toString(), style: Theme.of(context).textTheme.displaySmall),
                Icon(FontAwesomeIcons.arrowDown, size: 16, color: Theme.of(context).textTheme.displaySmall!.color)
              ],
             )
          )
        ],
      ),
    );
  }
}