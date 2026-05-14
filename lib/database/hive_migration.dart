import 'hive_db.dart';

class HiveMigration {
  static const int currentVersion = 1;

  static Future<void> run(HiveConnector db) async {
    final int from = db.loadSchemaVersion();
    if (from >= currentVersion) return;
    for (int v = from + 1; v <= currentVersion; v++) {
      await _migrate(db, v);
    }
    await db.saveSchemaVersion(currentVersion);
  }

  static Future<void> _migrate(HiveConnector db, int version) async {
    switch (version) {
      case 1:
        // Initial schema baseline — no data transformation needed.
        // Future cases: iterate db.getAllRecipes() / db.getUserBooks()
        // and backfill new required fields introduced in that version.
        break;
    }
  }
}
