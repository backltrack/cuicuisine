import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:cuicuisine/utilities/web_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:diacritic/diacritic.dart';

import '../models/data_model.dart';
import '../database/database_mgr.dart';
import '../utilities/string_functions.dart';
import '../fonts/custom_icons.dart';
import '../generated/l10n.dart';

import 'books/book_join_page.dart';
import 'books/book_name_page.dart';
import 'books/book_settings_page.dart';
import 'settings/general_settings_page.dart';
import 'recipes/recipe_page.dart';

import '../widgets/book_widgets/book_new_join_dialog.dart';
import '../widgets/core_widgets/circular_button.dart';
import '../widgets/core_widgets/my_outlined_button.dart';
import '../widgets/core_widgets/search_app_bar.dart';
import '../widgets/core_widgets/alert_dialog.dart';
import '../widgets/recipe_widgets/bottom_action_bar.dart';
import '../widgets/recipe_widgets/recipe_card_tile.dart';
import '../widgets/recipe_widgets/recipe_list_tile.dart';
import '../widgets/recipe_widgets/filter_bottom_menu.dart';
import '../widgets/recipe_widgets/recipe_popup_menu.dart';
import '../widgets/recipe_widgets/book_picker_popup.dart';

class HomePage extends StatefulWidget {
  static const String route = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Book>? books;
  List<Recipe>? recipes;
  Book? selectedBook;
  AccessLevel userAccess = AccessLevel.read;

  bool askForBookCreation = false;

  // filtering variables
  bool _displayFavorites = false;
  int _time = 0;
  bool _isTimeMax = false;
  List<String> _mandatoryIngredients = [];
  List<String> _mandatoryTags = [];
  
  // sort and display variables
  String _sortingMethod = "alphaDown";
  bool _isListed = true;

  // research variable
  String _research = "";

  // popup menu position and selection
  Offset _tapPosition = const Offset(0, 0);

  // vibration access
  // bool canVibrate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {

    // check if vibration available
    // if (!kIsWeb) {
    //   canVibrate = await Vibrate.canVibrate;
    // }

    // load books
    books = DatabaseMgr().localMgr.getUserBooks();

    // set default Book
    String? defaultBook = DatabaseMgr().localMgr.loadCurrentBook();

    // select book and load recipes
    if (books != null && books!.isNotEmpty) {
      if (defaultBook != null) {
        Book? foundBook = findBookFromId(defaultBook);
        if (foundBook != null) {
          // set current book
          selectedBook = foundBook;
          //get recipes and set tags and ingredients names to book
          recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
          await DatabaseMgr().localMgr.updateTagsAndIngredients();
          // get user access
          userAccess = selectedBook!.access[DatabaseMgr().localMgr.getUserId()] ?? AccessLevel.read;
          // refresh UI
          setState(() {});
        }
        else {
          await setBookAsDefaultAndRefresh(books![0]);
        }
      } else {
        await setBookAsDefaultAndRefresh(books![0]);
      }
    } else {
      // books is empty or null
      if (books != null) {
        // No book available
        setState(() {
          askForBookCreation = true;
          // notify that books is empty and not null
          books = [];
        });
      }
    }
  }

  void _showCustomMenu(Recipe recipe) {
    final RenderObject? overlay = Overlay.of(context).context
        .findRenderObject();

    if (overlay != null) {
      showMenu(
          context: context,
          items: makeRecipePopupMenu(context, userAccess),
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40), // smaller rect, the touch area
              Offset.zero & overlay.semanticBounds
                  .size // Bigger rect, the entire screen
          )
      )
      // This is how you handle user selection
          .then((item) async {
        // delta would be null if user taps on outside the popup menu
        // (causing it to close without making selection)
        if (item == null) return;

        if (item is String) {
          switch (item) {
            case "copy_into":
              return showBookPickerDialog(
                  context: context,
                  books: DatabaseMgr().localMgr.getUserBooks(getWritableOnly: true)
              ).then((bookId) async {
                if (bookId != null) {
                  print("add ${recipe.name} to $bookId");
                  DatabaseMgr().localMgr.duplicateRecipe(recipe, bookId);
                  // update books and recipes
                  books = DatabaseMgr().localMgr.getUserBooks();
                  recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
                  setState(() {});
                }
              });
            case "remove":
              return showAlertDialog(
                  context: context,
                  title: S.of(context).popup_delete_title,
                  description: userAccess.index <= AccessLevel.read.index ?
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(S.of(context).popup_delete_ownership_warning, textAlign: TextAlign.center),
                          Text(S.of(context).popup_delete_description_as_collaborator, textAlign: TextAlign.center),
                          Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          Text(S.of(context).popup_delete_description_user_warning, textAlign: TextAlign.center)
                        ],
                      )
                      :
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(S.of(context).popup_delete_description_as_owner, textAlign: TextAlign.center),
                          Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          Text(S.of(context).popup_delete_description_user_warning, textAlign: TextAlign.center)
                        ],
                      )
              ).then((value) async {
                if (value != null && value) {
                  DatabaseMgr().localMgr.deleteRecipe(recipe.id);
                  // update book recipes
                  recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
                  setState(() {});
                }
              });
            default:
              throw UnimplementedError();
          }
        }
      });
    }
    else {
      print("Can't show menu");
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  Book? findBookFromId(String bookId) {
    for (Book book in books!) {
      if (book.id == bookId) {
        // set current book
        return book;
      }
    }
    return null;
  }

  Future<void> setBookAsDefaultAndRefresh(Book book) async {
    selectedBook = book;
    // store new default book
    DatabaseMgr().localMgr.saveCurrentBook(book.id);
    //get recipes and set tags and ingredients names to book
    recipes = DatabaseMgr().localMgr.getRecipesFromBook(book.id);
    await DatabaseMgr().localMgr.updateTagsAndIngredients();
    // get user access
    userAccess = DatabaseMgr().localMgr.getUserAccess(book.id) ?? AccessLevel.read;
    // refresh UI
    setState(() {});
  }

  Future<void> addNewBook() async {
    await showAddBookDialog(context: context).then((value) {
      if (value is String && value == "new") {
        Navigator.of(context).pushNamed(BookNamePage.route, arguments: {
          'isBookCreation': true
        }).then((value) async {
          if (value != null) {
            if (value is Book?) {
              Book? newBook = value as Book?;
              if (newBook != null) {
                // load future books
                books = DatabaseMgr().localMgr.getUserBooks();
                // set new book as selected book
                await setBookAsDefaultAndRefresh(newBook);
              }
            }
          }
        });
      } else if (value is String && value == "join") {
        Navigator.of(context).pushNamed(BookJoinPage.route).then((value) async {
          if (value != null) {
            if (value is Book) {
              // load future books
              books = DatabaseMgr().localMgr.getUserBooks();
              // set new book as selected book
              await setBookAsDefaultAndRefresh(value);
            }
          }
        });
      }
    }
    );
  }

  Future<void> refreshData() async {
    await DatabaseMgr().remoteMgr.testConnexion();
    print("isOnline: ${DatabaseMgr().isOnline}");
    if (DatabaseMgr().isOnline) {
      await DatabaseMgr().synchronization.sync();
    }
    // reload books
    books = DatabaseMgr().localMgr.getUserBooks();
    // set selected book
    if (selectedBook != null) {
      Book? foundBook = findBookFromId(selectedBook!.id);
      if (foundBook != null) {
        selectedBook = foundBook;
      } else {
        // current book has been deleted
        if (books!.isNotEmpty) {
          print('set first as default');
          selectedBook = books![0];
        } else {
          print('no more book');
          selectedBook = null;
          return;
        }
      }
      // reload recipes
      recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
      await DatabaseMgr().localMgr.updateTagsAndIngredients();
      // get user access
      userAccess = DatabaseMgr().localMgr.getUserAccess(selectedBook!.id) ?? AccessLevel.read;

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (askForBookCreation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        addNewBook();
      });
      askForBookCreation = false;
    }
    
    return Scaffold(
        appBar: SearchAppBar(
          myTitle: selectedBook != null ? selectedBook!.name : S.of(context).title,
          onSearchChanged: (String val) {
            setState(() {
              _research = val;
            });
          },
          extraWebButton: IconButton(
            icon: const FaIcon(FontAwesomeIcons.download),
            onPressed: () async {
              String? apkPath = await DatabaseMgr().remoteMgr.getLatestApk();
              if (apkPath != null) {
                downloadFile("${DatabaseMgr().localMgr.getServerUri()!}$apkPath");
              }
            },
          )
        ),
        drawer: homepageDrawer(DatabaseMgr().localMgr.getUser()),
        onDrawerChanged: (isOpened) async {
            if (isOpened) {
              await DatabaseMgr().remoteMgr.testConnexion();
              setState(() {});
            }
          },
        body:
          selectedBook == null ?
          ListTile(
            title: Text(S.of(context).book_choice),
          ):
          RefreshIndicator(
            onRefresh: refreshData,
            child: Builder(
              builder: (context) {
                if (recipes != null && recipes!.isNotEmpty) {

                  // sort Recipe list
                  List<Recipe> sortedData = List<Recipe>.from(recipes!);
                  if (_sortingMethod == "alphaDown") {
                    sortedData.sort((Recipe a, Recipe b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                  } else if (_sortingMethod == "alphaUp") {
                    sortedData.sort((Recipe a, Recipe b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                  } else if (_sortingMethod == "timeDown") {
                    sortedData.sort((Recipe a, Recipe b) => a.getTotalTime().compareTo(b.getTotalTime()));
                  } else if (_sortingMethod == "timeUp") {
                    sortedData.sort((Recipe a, Recipe b) => b.getTotalTime().compareTo(a.getTotalTime()));
                  } else if (_sortingMethod == "lastUpdatedDown") {
                    sortedData.sort((Recipe a, Recipe b) => b.lastUpdate!.compareTo(a.lastUpdate!));
                  } else if (_sortingMethod == "lastUpdatedUp") {
                    sortedData.sort((Recipe a, Recipe b) => a.lastUpdate!.compareTo(b.lastUpdate!));
                  }

                  return ListView.builder(
                    key: UniqueKey(),
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: sortedData.length + 1,
                    itemBuilder: (context, index) {
                      void onTap() async {
                        final result = await Navigator.of(context).pushNamed("${RecipePage.route}/${sortedData[index].id}", arguments: {
                          'recipe': sortedData[index]
                        });
                        if (result != null && result == "reloadRecipes") {
                          print('reload');
                          recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
                          await DatabaseMgr().localMgr.updateTagsAndIngredients();
                          // refresh UI
                          setState(() {});
                        } else if (result != null && result == "reloadBooks") {
                          // get user books
                          books = DatabaseMgr().localMgr.getUserBooks();
                          setState(() {});
                        }
                      }

                      Widget returnedWidget = const SizedBox();

                      if (index == sortedData.length) {
                        return const SizedBox(height: 8);
                      }

                      // tags test
                      bool tagCondition = true;
                      for (String tag in _mandatoryTags) {
                        tagCondition = tagCondition && sortedData[index].tags.contains(tag);
                      }
                      // ingredient test
                      bool ingredientCondition = true;
                      for (String ingredient in _mandatoryIngredients) {
                        ingredientCondition =
                            ingredientCondition && List<String>.generate(sortedData[index].recipeIngredients.length,
                                (int i) => sortedData[index].recipeIngredients[i].name.toLowerCase().trim()).contains(ingredient.toLowerCase().trim());
                      }

                      if (_mandatoryTags.isNotEmpty && tagCondition || _mandatoryTags.isEmpty) {
                        if (_mandatoryIngredients.isNotEmpty && ingredientCondition || _mandatoryIngredients.isEmpty) {
                          AppUser? _appUser = DatabaseMgr().localMgr.getUser();
                          if (_displayFavorites && _appUser!.favoriteRecipes.contains(sortedData[index].id) || !_displayFavorites) {
                            if (_time > 0 && _isTimeMax && sortedData[index].getTotalTime() < _time ||
                                _time > 0 && !_isTimeMax && sortedData[index].getTotalTime() > _time ||
                                _time == 0) {
                              if (_research != "" && removeDiacritics(sortedData[index].name.toLowerCase()).contains(removeDiacritics(_research.toLowerCase())) || _research == "") {
                                if (_isListed) {
                                  returnedWidget = RecipeListTile(
                                    key: UniqueKey(),
                                    recipe: sortedData[index],
                                    onTap: onTap,
                                    onLongPress: () async {
                                      // if (canVibrate) {
                                      //   Vibrate.feedback(FeedbackType.medium);
                                      // }
                                      _showCustomMenu(sortedData[index]);
                                    },
                                    onTapDown: _storePosition,
                                  );
                                } else {
                                  returnedWidget = RecipeCardTile(
                                    key: UniqueKey(),
                                    recipe: sortedData[index],
                                  );
                                }
                              }
                            }
                          }
                        }
                      }
                      return  returnedWidget;
                    }
                  ); 
                }
                else if (recipes != null) {
                  return ListTile(
                    title: Text(S.of(context).no_recipe),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          ),

        floatingActionButton: (selectedBook == null || userAccess == AccessLevel.read) ? null : FloatingActionButton(
          onPressed: () async {
            String newRecipeId = await DatabaseMgr().localMgr.addNewRecipe(name: "", bookId: selectedBook!.id);
            // Edit recipe
            await Navigator.of(context).pushNamed("${RecipePage.route}/$newRecipeId", arguments: {
              'recipe': DatabaseMgr().localMgr.getRecipe(newRecipeId),
              'isNewRecipe': true
            });
            // reload
            books = DatabaseMgr().localMgr.getUserBooks();
            // set updated Book
            Book? foundBook = findBookFromId(selectedBook!.id);
            if (foundBook != null) {
              selectedBook = foundBook;
            }
            // reload recipes
            recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
            await DatabaseMgr().localMgr.updateTagsAndIngredients();
            // update UI
            setState(() {});
          },
          child: const Icon(Icons.add),
          

        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: selectedBook == null ? null : BottomActionBar(
          currentBook: selectedBook,
          onCloseFilters: () {
            setState(() {
              _displayFavorites = BottomActionBar.displayFavorites;
              _time = FilterBottomMenu.time;
              _isTimeMax = FilterBottomMenu.isTimeMax;
              _mandatoryIngredients = FilterBottomMenu.mandatoryIngredients;
              _mandatoryTags = FilterBottomMenu.mandatoryTags;
            });
          },
          onResetFilters: () {
            setState(() {
              _displayFavorites = BottomActionBar.displayFavorites;
              _time = FilterBottomMenu.time;
              _isTimeMax = FilterBottomMenu.isTimeMax;
              _mandatoryIngredients = FilterBottomMenu.mandatoryIngredients;
              _mandatoryTags = FilterBottomMenu.mandatoryTags;
            });
          },
          onSortingMethodChanged: () {
            setState(() {
              _sortingMethod = BottomActionBar.sortingMethod;
            });
          },
          onChangeDisplay: () {
            setState(() {
              _isListed = BottomActionBar.isListed;
            });
          },
        ),
    );
  }

  Drawer homepageDrawer(AppUser? appUser) {

    Widget addButton = MyOutlinedButton(
        text: S.of(context).add_button,
        icon: FontAwesomeIcons.plus,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        onPressed: addNewBook
    );

    return Drawer(
      child: Column(
        children: <Widget>[
          Stack(
            fit: StackFit.loose,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(appUser!.name),
                accountEmail: Text(appUser.email),
                currentAccountPicture: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                      child: Text(getInitials(appUser.name)),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          color: DatabaseMgr().isOnline ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        )
                      )
                    )
                  ]
                )
              ),
              if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows)
              Container(
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  onPressed: refreshData,
                  icon: const FaIcon(FontAwesomeIcons.arrowsRotate)
                )
              )
            ]
          ),

          if (books != null && books!.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemCount: books!.length + 1,
                itemBuilder: (context, int index) {
                  return index < books!.length  ?
                    ListTile(
                      key: UniqueKey(),
                      leading: FaIcon(books![index].access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.own ? FontAwesomeIcons.book :
                                        books![index].access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.write ? CustomIcons.book_write :
                                          CustomIcons.book_read),
                      title: Text(books![index].name),
                      textColor: selectedBook != null && selectedBook!.id == books![index].id ? ThemeMgr.getTheme(context)!.primaryColor : ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color,
                      iconColor: selectedBook != null && selectedBook!.id == books![index].id ? ThemeMgr.getTheme(context)!.primaryColor : ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color,
                      trailing: selectedBook != null && selectedBook!.id == books![index].id ? CircularIconButton(
                        icon: FaIcon(FontAwesomeIcons.gear, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
                        color: ThemeMgr.getTheme(context)!.cardColor,
                        onPressed: () {
                          Navigator.of(context).pushNamed("${BookSettingsPage.route}/${books![index].id}", arguments: {
                            'book': books![index]
                          }).then((value) async {
                            books = DatabaseMgr().localMgr.getUserBooks();

                            if (books != null) {
                              selectedBook = findBookFromId(selectedBook!.id);
                              if(selectedBook == null) {
                                // current book has been deleted
                                if (books!.isNotEmpty) {
                                  print('set first as default');
                                  selectedBook = books![0];
                                }
                                else {
                                  print('no more book');
                                }
                              }
                              setState(() {});
                            }
                          });
                        },
                      ) : null,
                      onTap: () async {
                        setBookAsDefaultAndRefresh(books![index]);
                        // pop
                        Navigator.pop(context);
                      },
                    ) :
                      addButton;
                }
              ),
            )
          else if (books != null && books!.isEmpty)
            ...[
            addButton,
            const Spacer()
            ]
          else
            ...[
              const CircularProgressIndicator(),
              const Spacer()
            ],

          const Divider(),
          ListTile(
            title: Text(S.of(context).settings),
            leading: const FaIcon(FontAwesomeIcons.gear),
            onTap: () {
              Navigator.of(context).pushNamed(GeneralSettingsPage.route);
            }
          )
        ],
      ),
    );
  }
}