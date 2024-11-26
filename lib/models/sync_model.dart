import 'package:hive/hive.dart';

import 'data_model.dart';

  part 'sync_model.g.dart';

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

  Operation({required this.type, required this.object, required this.id});
}


@HiveType(typeId: 14)
class OperationQueue extends HiveObject {
  @HiveField(0)
  List<String> queue = [];

  OperationQueue();

  void addOperation(String operationId) {
    queue.add(operationId);
    save();
    
    print('added');
    print(length());
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