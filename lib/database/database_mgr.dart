import 'package:cuicuisine/database/synchronization.dart';

import 'hive_db.dart';
import 'mongodb_connector.dart';

class DatabaseMgr {
  static final DatabaseMgr _instance = DatabaseMgr._();
  static late final HiveConnector localMgr;
  static late final MongoConnector remoteMgr;
  static late final Synchronization synchronization;

  static bool isOnline = false;

  factory DatabaseMgr() {
    return _instance;
  }

  DatabaseMgr._();

  static Future<void> initialize() async {
    localMgr = HiveConnector();
    await localMgr.initialize();

    // const String defaultServer = 'http://192.168.223.248:8000';
    // const String defaultServer = 'http://192.168.1.15:8000';
    const String defaultServer = 'http://192.168.1.28:8000';
    
    String? uri = localMgr.getServerUri();

    remoteMgr = MongoConnector(server: uri ?? defaultServer);
    
    synchronization = Synchronization();
  }
}