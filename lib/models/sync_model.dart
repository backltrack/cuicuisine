import 'package:hive/hive.dart';

import 'data_model.dart';
import 'update_model.dart';

  part 'sync_model.g.dart';

@HiveType(typeId: 9)
enum OperationType {
  @HiveField(0)
  create,
  @HiveField(1)
  delete,
  @HiveField(2)
  update
}

@HiveType(typeId: 8)
class Operation extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  OperationType type;
  @HiveField(2)
  DatabaseObject object;

  Operation({required this.type, required this.object, required this.id});

  dynamic getTypedObject() {
    if (type == OperationType.update) {
      if (object is UserUpdate) {
        return object as UserUpdate;
      }
      else if (object is BookUpdate) {
        return object as BookUpdate;
      }
      else if (object is RecipeUpdate) {
        return object as RecipeUpdate;
      }
    }
    else {
      if (object is AppUser) {
        return object as AppUser;
      }
      else if (object is Book) {
        return object as Book;
      }
      else if (object is Recipe) {
        return object as Recipe;
      }
    }
  }
}


@HiveType(typeId: 7)
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