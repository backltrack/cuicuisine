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
    
    Operation? ope = await _localMgr.getFirstOperation();
    print("operation queue length: ${_localMgr.getQueueLength()}");
    List<Operation> failedOperations = [];

    while (ope != null) {
      OperationResultAction operationResultAction = OperationResultAction.requeue;
      switch (ope.type) {
        case OperationType.create:
          operationResultAction = await createObject(ope.object);
        case OperationType.update:
          operationResultAction = await updateObject(ope.object);
        case OperationType.delete:
          operationResultAction = await deleteObject(ope.object);
      }
      if (operationResultAction == OperationResultAction.requeue) {
        failedOperations.add(ope);
      }

      print("operation queue length: ${_localMgr.getQueueLength()}");
      ope = await _localMgr.getFirstOperation();
      print("operation queue length: ${_localMgr.getQueueLength()}");
    }

    if (failedOperations.isEmpty) {
      return true;
    }
    else {
      for (Operation ope in failedOperations) {

        print("re-adding failed operation to queue: ${ope.type} ${ope.object}");
        if (ope.object is RecipeUpdate && ope.type == OperationType.update) {
          RecipeUpdate update = ope.object as RecipeUpdate;
          print("${update.toJson()}");
        }
        if (ope.object is BookUpdate && ope.type == OperationType.update) {
          BookUpdate update = ope.object as BookUpdate;
          print("${update.toJson()}");
        }
        if (ope.object is RecipeImage && ope.type == OperationType.create) {
          RecipeImage update = ope.object as RecipeImage;
          print(update.path);
        }
        _localMgr.addQueueOperation(type: ope.type, object: ope.object, pushAfter: false);
      }
      return false;
    }
  }

  Future<bool> fetchNew() async {
    String? lastChange = DatabaseMgr().localMgr.getLastChange();
    print("Last change: $lastChange");

    if (lastChange != null) {
      // already sync before
      bool result = await DatabaseMgr().remoteMgr.getLatestChanges(lastChange);
      if (!result) {
        await DatabaseMgr().remoteMgr.fetchAllFromUser();
      }
    }
    else {
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

  Future<OperationResultAction> createObject(object) async {
    if (object is Book) {
      return await _remoteMgr.createBook(object);
    }
    else if (object is Recipe) {
      return await _remoteMgr.createRecipe(object);
    }
    else if (object is RecipeImage) {
      return await _remoteMgr.uploadImage(object);
    }

    return OperationResultAction.requeue;
  }

  Future<OperationResultAction> updateObject(object) async {
    if (object is UserUpdate) {
      return await _remoteMgr.updateUser(object);
    }
    else if (object is BookUpdate) {
      return await _remoteMgr.updateBook(object);
    }
    else if (object is RecipeUpdate) {
      return await _remoteMgr.updateRecipe(object);
    }

    return OperationResultAction.requeue;
  }

  Future<OperationResultAction> deleteObject(object) async {
    if (object is AppUser) {

    }
    else if (object is Book) {
      return await _remoteMgr.deleteBook(object);
    }
    else if (object is Recipe) {
      return await _remoteMgr.deleteRecipe(object);
    }
    else if (object is RecipeImage) {
      return await _remoteMgr.deleteImage(object.recipeId, object.imageId);
    }

    return OperationResultAction.requeue;
  }
}