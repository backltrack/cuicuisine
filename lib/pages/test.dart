
import 'package:cuicuisine/database/database_mgr.dart';
import 'package:cuicuisine/models/data_model.dart';
import 'package:cuicuisine/models/update_model.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  static const String route = '/test';

  @override
  _TestPage createState() => _TestPage();
}

class _TestPage extends State<TestPage> {
  String txt = "";

  String connexionState = "";

  ScrollController scrollController = ScrollController();

  void setConnexionState() {
    setState(() {
      connexionState = DatabaseMgr().isOnline ? "Is Online" : "Is Offline";
    });
  }

  @override
  void initState() {
    super.initState();

    setConnexionState();

    DatabaseMgr().addListener(setConnexionState);
  }

  @override
  void dispose() {
    DatabaseMgr().removeListener(setConnexionState);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Page"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await DatabaseMgr().remoteMgr.testConnexion();
        },
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              Row(
                children: [
                  Text(connexionState)
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  DatabaseMgr().localMgr.updateUser(name: "Sug'");

                },
                child: const Text("Update User") 
              ),
              ElevatedButton(
                onPressed: () async {
                  DatabaseMgr().localMgr.addNewBook('test from app');

                },
                child: const Text("Add Book") 
              ),
              ElevatedButton(
                onPressed: () async {
                  List<Book> books = DatabaseMgr().localMgr.getUserBooks();
                  BookUpdate bookUpdate = BookUpdate(id: books.last.id, name: "super book", users: [...books.last.users, "fake user id"]);
                  DatabaseMgr().localMgr.updateBook(books.last.id, bookUpdate);
                },
                child: const Text("Update Book") 
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    List<Book> books = DatabaseMgr().localMgr.getUserBooks();
                    txt = books.isNotEmpty ? "${books.toString()} / ${DatabaseMgr().localMgr.getBooksNum()}" : "not created, 0/${DatabaseMgr().localMgr.getBooksNum()}";
                  });
                },
                child: const Text("Get books")
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    DatabaseMgr().localMgr.addNewRecipe(name: 'toUpdate');
                    // txt = .id;
                  });
                },
                child: const Text("Add recipe")
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    List<Recipe> recipes = DatabaseMgr().localMgr.getAllRecipes();
                    RecipeUpdate recipeUpdate = RecipeUpdate(id: recipes.last.id, name: 'test', preparationTime: 2, cookingTime: 10, quantity: 2, recipeIngredients: [Ingredient(name: 'carotte', quantity: 10, unit: "kg")], steps: [RecipeStep(step: "<p>bla bla</p>", time: 10)]);
                    DatabaseMgr().localMgr.updateRecipe(recipes.last.id, recipeUpdate);
                  });
                },
                child: const Text("Update recipe")
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    List<Recipe> recipes = DatabaseMgr().localMgr.getAllRecipes();
                    txt = recipes.isNotEmpty ? "${recipes.length}\n${recipes.last.id}\n${recipes.last.toJson()}" : "not created";
                  });
                },
                child: const Text("Get recipes")
              ),

              Text(txt)
            ]
          ),
        )
      ),
    );
  }
}