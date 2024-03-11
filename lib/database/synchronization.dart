import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/models/model.dart';

import './hive_db.dart';
import './mongodb_connector.dart';
class Synchronization {
  final MongoConnector _remoteMgr = DatabaseMgr.remoteMgr;
  final HiveConnector _localMgr = DatabaseMgr.localMgr;

  Synchronization();

// Fetch
  Future<void> fetchAll() async {
    // user uid must be already set
    // retrieve all user relative data from MongoDB
    // clear and populate Hive
    
    // _localMgr.clearAll();

    // await fetchUser();
    // await fetchUserBooks();
    // await fetchUserBooksRecipes();
  }

  // Future<void> fetchUser() async {
  //   // user uid must be already set
  //   // update Hive user from MongoDB data
  //   AppUser? currentHiveUser = _localMgr.getUser();
  //   if (currentHiveUser != null)
  //   {
  //     try {
  //       AppUser mongoUser = await _remoteMgr.fetchUser(currentHiveUser.firebaseId);
  //       _localMgr.setUser(mongoUser);
  //     } on Exception catch(e) {
  //       throw Exception(e);
  //     }
  //   }
  // }

  // Future<void> fetchBook(String id) async {
  //   Book mongoBook = await _remoteMgr.fetchBook(id);        
  //   _localMgr.deleteBook(id);
  //   _localMgr.addBook(mongoBook);
  // }

  // Future<void> fetchUserBooks() async {
  //   // retrieve accessible books for current user 
  //   String? currentUserUid = _localMgr.getUserUid();
  //   if (currentUserUid != null)
  //   {
  //     try {
  //       List<Book> userBooks = await _remoteMgr.getUserBooks(currentUserUid);
  //       _localMgr.clearBooks();
  //       for (Book book in userBooks) {
  //         _localMgr.addBook(book);
  //       }
  //     } on Exception catch(e) {
  //       throw Exception(e);
  //     }
  //   }
  // }

  // Future<void> fetchRecipe(String id) async {
  //   Recipe mongoRecipe = await _remoteMgr.fetchRecipe(id);        
  //   _localMgr.deleteRecipe(id);
  //   _localMgr.addRecipe(mongoRecipe);
  // }

  // Future<void> fetchBookRecipes(String id) async {
  //   // retrieve all recipes from book id
  //   List<Recipe> recipes = await _remoteMgr.getBookRecipes(id);
  //   for (Recipe recipe in recipes) {
  //     Recipe? hiveRecipe = _localMgr.getRecipe(recipe.uid);
  //     if (hiveRecipe != null) {
  //       if (hiveRecipe.lastUpdate!.compareTo(recipe.lastUpdate!) < 0) {
  //         // update only if newer from MongoDB
  //         _localMgr.deleteRecipe(recipe.uid);
  //         _localMgr.addRecipe(recipe);
  //       }
  //     }
  //     else {
  //       // add if doesn't exists in Hive
  //       _localMgr.addRecipe(recipe);
  //     }
  //   }
  // }

  // Future<void> fetchUserBooksRecipes() async {
  //   // retrieve all recipes from all user books
  //   String? currentUserUid = _localMgr.getUserUid();
  //   if (currentUserUid != null)
  //   {
  //     try {
  //       List<Book> books =_localMgr.getUserBooks();
  //       for (Book book in books) {
  //         await fetchBookRecipes(book.uid);
  //       }

  //     } on Exception catch(e) {
  //       throw Exception(e);
  //     }
  //   }
  // }


  // // sync
  // Future<void> syncAll() async {
  //   await syncUser();
  //   await syncBooks();
  //   await syncRecipes();
  // }

  // Future<void> syncRecipe(String id) async {
  //   Recipe? localRecipe = _localMgr.getRecipe(id);
  //   bool recipeExistsInMongo = await _remoteMgr.recipeExsits(id);
    
  //   if (localRecipe != null && recipeExistsInMongo) {
  //     // update recipe
  //     DateTime lastMongoUpdate = await _remoteMgr.getRecipeLastUpdate(id);
  //     if (lastMongoUpdate.compareTo(localRecipe.lastUpdate!) > 0) {
  //       // need local update
  //       await fetchRecipe(id);
  //     }
  //     else if (lastMongoUpdate.compareTo(localRecipe.lastUpdate!) < 0) {
  //       // need mongo update
  //       await _remoteMgr.updateRecipe(localRecipe);
  //     }
  //   }
  //   else if (localRecipe != null && !recipeExistsInMongo) {
  //     // create recipe in Mongo
  //     await _remoteMgr.createRecipe(localRecipe);
  //   }
  //   else if (recipeExistsInMongo && localRecipe == null) {
  //     // fetch recipe
  //     await fetchRecipe(id);
  //   }
  // }

  // Future<void> syncRecipes() async {

  // }

  // Future<void> syncBook(String id) async {
  //   Book? localBook = _localMgr.getBook(id);
  //   bool bookExistsInMongo = await _remoteMgr.bookExsits(id);
    
  //   if (localBook != null && bookExistsInMongo) {
  //     // update book
  //     DateTime lastMongoUpdate = await _remoteMgr.getBookLastUpdate(id);
  //     if (lastMongoUpdate.compareTo(localBook.lastUpdate!) > 0) {
  //       // need local update
  //       await fetchBook(id);
  //     }
  //     else if (lastMongoUpdate.compareTo(localBook.lastUpdate!) < 0) {
  //       // need mongo update
  //       await _remoteMgr.updateBook(localBook);
  //     }
  //   }
  //   else if (localBook != null && !bookExistsInMongo) {
  //     // create book in Mongo
  //     await _remoteMgr.createBook(localBook);
  //   }
  //   else if (bookExistsInMongo && localBook == null) {
  //     // fetch book
  //     await fetchBook(id);
  //   }
  // }

  // Future<void> syncBooks() async {
  //   List<Book> hiveBooks = _localMgr.getUserBooks();
  //   List<String> mongoBooksId = await _remoteMgr.getUserBooksId(_localMgr.getUserUid()!);

  //   // construct list of books (remote + local)
  //   List<String> booksId = [];

  //   for (Book book in hiveBooks) {
  //     booksId.add(book.uid);
  //   }
  //   for (String id in mongoBooksId) {
  //     if (!booksId.contains(id)) {
  //       booksId.add(id);
  //     }
  //   }
  // }

  // Future<void> syncUser() async {
  //   AppUser? currentUser = _localMgr.getUser();
  //   if (currentUser != null) {
  //     // update user
  //     DateTime lastMongoUpdate = await _remoteMgr.getUserLastUpdate(currentUser.firebaseId);
  //     if (lastMongoUpdate.compareTo(currentUser.lastUpdate!) > 0) {
  //       // need local update
  //       await fetchUser();
  //     }
  //     else if (lastMongoUpdate.compareTo(currentUser.lastUpdate!) < 0) {
  //       // need mongo update
  //       await _remoteMgr.updateUser(currentUser);
  //     }
  //   }
  // }
}