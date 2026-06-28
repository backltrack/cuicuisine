import 'package:hive/hive.dart';

import 'data_model.dart';
import '../utilities/logger.dart';

part 'sync_model.g.dart';

final _log = Logger('SyncModel');

enum UpdateStatus {
  success,
  notAuthorized,
  notFound,
  conflict,
  error;

  static UpdateStatus getStatusFromCode(int code) {
    switch (code) {
      case 0:
        return UpdateStatus.success;
      case 1:
        return UpdateStatus.notAuthorized;
      case 2:
        return UpdateStatus.notFound;
      case 3:
        return UpdateStatus.conflict;
      default:
        return UpdateStatus.error;
    }
  }

  static UpdateStatus getStatusFromHttpCode(int code) {
    switch (code) {
      case 200:
      case 201:
        return UpdateStatus.success;
      case 403:
        return UpdateStatus.notAuthorized;
      case 404:
        return UpdateStatus.notFound;
      case 409:
        return UpdateStatus.conflict;
      default:
        return UpdateStatus.error;
    }
  }
}

enum OperationResultAction {
  requeue,
  delete;
  
  static getActionFromUpdateStatus(UpdateStatus status) {
    _log.fine("getting action from status: $status");
    switch (status) {
      case UpdateStatus.success:
        // delete operation because it was successful
        return delete;
      case UpdateStatus.notAuthorized:
        // delete operation because it cannot be performed
        return delete;
      case UpdateStatus.notFound:
        // delete operation because it cannot be performed
        return delete;
      case UpdateStatus.conflict:
        // delete operation because it cannot be performed
        return delete;
      case UpdateStatus.error:
        // requeue operation because it might work later
        return requeue;
    }
  }
}

class OperationResult {
  OperationResultAction action;
  UpdateStatus status;

  OperationResult({required this.action, required this.status});
}

@HiveType(typeId: 12)
enum OperationType {
  @HiveField(0)
  create,
  @HiveField(1)
  delete,
  @HiveField(2)
  update
}

@HiveType(typeId: 13)
class Operation extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  OperationType type;
  @HiveField(2)
  DatabaseObject object;
  @HiveField(3)
  String? targetBookId;

  Operation({required this.type, required this.object, required this.id, this.targetBookId});
}


@HiveType(typeId: 14)
class OperationQueue extends HiveObject {
  @HiveField(0)
  List<String> queue = [];

  OperationQueue();

  void addOperation(String operationId) {
    queue.add(operationId);
    save();
    
    _log.fine("operation added, queue length: ${length()}");
  }

  String? getFirstOperationId() {
    if (queue.isNotEmpty ) {
      String id = queue.removeAt(0);
      save();
      return id;
    }
    return null;
  }

  int length() {
    return queue.length;
  }
}

class MongoChange {
  String changeId;
  String objectType;
  OperationType operationType;
  String objectId;

  MongoChange(this.changeId, this.objectType, this.operationType, this.objectId);

  factory MongoChange.fromJson(Map<String, dynamic> data) {
    return MongoChange(data['changeId'], data['objectType'], OperationType.values[data['operationType'] as int], data['objectId']);
  }
}