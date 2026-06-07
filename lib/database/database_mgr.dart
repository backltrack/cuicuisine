import 'package:cuicuisine/database/synchronization.dart';
import 'package:flutter/foundation.dart';

import 'hive_db.dart';
import 'mongodb_connector.dart';

class DatabaseMgr with ChangeNotifier {
  static final DatabaseMgr _instance = DatabaseMgr._();
  late final HiveConnector localMgr;
  late final MongoConnector remoteMgr;
  late final Synchronization synchronization;

  bool _isOnline = false;
  bool _isCompatible = true; // optimistic: stays true until server says otherwise
  double? _syncProgress;

  String? pendingDeepLinkRecipeId;

  bool get isOnline => _isOnline;
  bool get isCompatible => _isCompatible;
  double? get syncProgress => _syncProgress;

  set isOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  set isCompatible(bool value) {
    _isCompatible = value;
    notifyListeners();
  }

  set syncProgress(double? value) {
    _syncProgress = value;
    notifyListeners();
  }

  factory DatabaseMgr() {
    return _instance;
  }

  DatabaseMgr._();

  Future<void> initialize() async {
    localMgr = HiveConnector();
    await localMgr.initialize();

    // const String defaultServer = 'https://localhost:8000';
    // const String defaultServer = 'https://192.168.1.28:8000';
    const String defaultServer = 'https://mycuicuisine.duckdns.org:8000';
    
    String? uri = localMgr.getServerUri();

    if (uri == null) {
      localMgr.saveServerUri(defaultServer);
    }

    remoteMgr = MongoConnector(server: uri ?? defaultServer);
    
    synchronization = Synchronization();
  }
}