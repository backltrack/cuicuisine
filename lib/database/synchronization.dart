import './database_mgr.dart';
import '../models/data_model.dart';
import '../models/update_model.dart';
import '../models/sync_model.dart';

import './hive_db.dart';
import './mongodb_connector.dart';


class Synchronization {
  final MongoConnector _remoteMgr = DatabaseMgr().remoteMgr;
  final HiveConnector _localMgr = DatabaseMgr().localMgr;

  Synchronization();

  Future<bool> pushQueue() async {
    // Push Queue
    // create operation -> push
    // delete operation -> check last update
      // Queue document more recent -> push
      // server document more recent -> conflict
    // update operation -> check last update 
      // Queue document more recent -> push
      // server document more recent -> conflict
    
    Operation? ope = _localMgr.getFirstOperation();
    print(_localMgr.getQueueLength());
    List<Operation> failedOperations = [];

    while (ope != null) {
      bool success = false;
      switch (ope.type) {
        case OperationType.create:
          success = await createObject(ope.object);
        case OperationType.update:
          success = await updateObject(ope.object);
        case OperationType.delete:
          success = await deleteObject(ope.object);
      }
      if (!success) {
        failedOperations.add(ope);
      }

      print(_localMgr.getQueueLength());
      ope = _localMgr.getFirstOperation();
      print(_localMgr.getQueueLength());
    }

    if (failedOperations.isEmpty) {
      return true;
    }
    else {
      for (Operation ope in failedOperations) {
        _localMgr.addQueueOperation(type: ope.type, object: ope.object, pushAfter: false);
      }
      return false;
    }
  }

  Future<bool> fetchNew() async {
    String? lastChange = DatabaseMgr().localMgr.getLastChange();
    print(lastChange);

    if (lastChange != null) {
      await DatabaseMgr().remoteMgr.getLatestChanges(lastChange);
    }
    else {
      print("fetch all");
      await DatabaseMgr().remoteMgr.fetchAllFromUser();
    }
    return true;
  }

  Future<bool> sync() async {
    // send all local document type, id, last update
    // server sends back all new or updated documents
    // refresh UI
    await fetchNew();

    //push queue
    await pushQueue();

    return true;
  }

  Future<bool> createObject(object) async {
    if (object is Book) {
      return await _remoteMgr.createBook(object);
    }
    else if (object is Recipe) {
      return await _remoteMgr.createRecipe(object);
    }
    else if (object is RecipeImage) {
      return await _remoteMgr.uploadImage(object);
    }

    return false;
  }

  Future<bool> updateObject(object) async {
    if (object is UserUpdate) {
      return await _remoteMgr.updateUser(object);
    }
    else if (object is BookUpdate) {
      return await _remoteMgr.updateBook(object);
    }
    else if (object is RecipeUpdate) {
      return await _remoteMgr.updateRecipe(object);
    }

    return false;
  }

  Future<bool> deleteObject(object) async {
    if (object is AppUser) {

    }
    else if (object is Book) {
      return await _remoteMgr.deleteBook(object);
    }
    else if (object is Recipe) {
      return await _remoteMgr.deleteRecipe(object);
    }

    return true;
  }
}