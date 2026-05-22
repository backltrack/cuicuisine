import '../utilities/logger.dart';
import '../utilities/toast_notifier.dart';
import './database_mgr.dart';
import '../models/data_model.dart';
import '../models/update_model.dart';
import '../models/sync_model.dart';
import './hive_db.dart';
import './mongodb_connector.dart';

final _log = Logger('Synchronization');


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
    _log.fine("operation queue length: ${_localMgr.getQueueLength()}");
    List<Operation> failedOperations = [];

    int successCount = 0;
    int notAuthorizedCount = 0;
    int notFoundCount = 0;
    int conflictCount = 0;

    while (ope != null) {
      OperationResult operationResult = OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);

      switch (ope.type) {
        case OperationType.create:
          operationResult = await createObject(ope.object);
        case OperationType.update:
          operationResult = await updateObject(ope.object);
        case OperationType.delete:
          operationResult = await deleteObject(ope.object);
      }
      _log.fine("${ope.id}: ${operationResult.action} ${operationResult.status}");
      if (operationResult.action == OperationResultAction.requeue) {
        failedOperations.add(ope);
      }
      else {
        switch (operationResult.status) {
          case UpdateStatus.success:
            successCount++;
          case UpdateStatus.notAuthorized:
            notAuthorizedCount++;
          case UpdateStatus.notFound:
            notFoundCount++;
          case UpdateStatus.conflict:
            conflictCount++;
          case UpdateStatus.error:
            // should never happen
            throw UnimplementedError();
        }
      }

      ope = await _localMgr.getFirstOperation();
    }
    if (successCount > 0) {
      ToastNotifier().showSuccess("$successCount operations pushed");
    }
    if (notAuthorizedCount > 0) {
      ToastNotifier().showError("$notAuthorizedCount operations failed: not authorized");
    }
    if (notFoundCount > 0) {
      ToastNotifier().showError("$notFoundCount operations failed: not found");
    }
    if (conflictCount > 0) {
      ToastNotifier().showError("$conflictCount operations failed: conflict");
    }

    if (failedOperations.isEmpty) {
      return true;
    }
    else {
      for (Operation ope in failedOperations) {

        _log.warning("re-queuing failed operation: ${ope.type} ${ope.object}");
        if (ope.object is RecipeUpdate && ope.type == OperationType.update) {
          _log.fine((ope.object as RecipeUpdate).toJson().toString());
        }
        if (ope.object is BookUpdate && ope.type == OperationType.update) {
          _log.fine((ope.object as BookUpdate).toJson().toString());
        }
        if (ope.object is RecipeImage && ope.type == OperationType.create) {
          _log.fine((ope.object as RecipeImage).path);
        }
        _localMgr.addQueueOperation(type: ope.type, object: ope.object, pushAfter: false);
      }
      ToastNotifier().showWarning("${failedOperations.length} operations failed to push, re-queued");

      return false;
    }
  }

  Future<bool> fetchNew() async {
    String? lastChange = DatabaseMgr().localMgr.getLastChange();
    _log.fine("last change: $lastChange");

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
    if (!DatabaseMgr().isCompatible) return false;

    bool isOnline = await DatabaseMgr().remoteMgr.testConnexion();
    if (!isOnline) {
      return false;
    }

    await fetchNew();

    await pushQueue();

    return true;
  }

  Future<OperationResult> createObject(object) async {
    if (object is Book) {
      return await _remoteMgr.createBook(object);
    }
    else if (object is Recipe) {
      return await _remoteMgr.createRecipe(object);
    }
    else if (object is RecipeImage) {
      return await _remoteMgr.uploadImage(object);
    }

    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<OperationResult> updateObject(object) async {
    if (object is UserUpdate) {
      return await _remoteMgr.updateUser(object);
    }
    else if (object is BookUpdate) {
      return await _remoteMgr.updateBook(object);
    }
    else if (object is RecipeUpdate) {
      return await _remoteMgr.updateRecipe(object);
    }

    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }

  Future<OperationResult> deleteObject(object) async {
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

    return OperationResult(action: OperationResultAction.requeue, status: UpdateStatus.error);
  }
}