import 'package:cuicuisine/pages/recipes/recipe_name_page.dart';
import 'package:cuicuisine/themes/theme_mgr.dart';
import 'package:cuicuisine/utilities/web_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:diacritic/diacritic.dart';

import '../models/data_model.dart';
import '../database/database_mgr.dart';
import '../utilities/string_functions.dart';
import '../utilities/toast_notifier.dart';
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
import '../widgets/recipe_widgets/recipe_panel_widget.dart';
import '../utilities/breakpoints.dart';
import '../utilities/logger.dart';

final _log = Logger('HomePage');

class HomePage extends StatefulWidget {
  static const String route = '/home';

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Book>? books;
  List<Recipe>? recipes;
  Book? selectedBook;
  AccessLevel userAccess = AccessLevel.read;

  // Recipe shown in the ultra-wide third column (≥ 1200px)
  Recipe? _panelRecipe;

  bool askForBookCreation = false;

  // filtering variables
  bool _displayFavorites = false;
  int _time = 0;
  bool _isTimeMax = false;
  List<String> _mandatoryIngredients = [];
  List<Tag> _mandatoryTags = [];
  
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
    DatabaseMgr().addListener(_onDatabaseMgrChanged);
    init();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingDeepLink());
  }

  @override
  void dispose() {
    DatabaseMgr().removeListener(_onDatabaseMgrChanged);
    super.dispose();
  }

  void _onDatabaseMgrChanged() {
    if (mounted) setState(() {});
  }

  void init() async {

    // check if vibration available
    // if (!kIsWeb) {
    //   canVibrate = await Vibrate.canVibrate;
    // }

    // load books
    books = DatabaseMgr().localMgr.getUserBooks();

    // set default Book
    String? defaultBook = DatabaseMgr().localMgr.getCurrentBookId();

    // select book and load recipes
    if (books != null && books!.isNotEmpty) {
      if (defaultBook != null) {
        Book? foundBook = findBookFromId(defaultBook);
        if (foundBook != null) {
          // set current book
          selectedBook = foundBook;
          //get recipes and set tags and ingredients names to book
          recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
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
                  _log.fine("copying '${recipe.name}' to $bookId");
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
      _log.warning("overlay not found, cannot show menu");
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
    DatabaseMgr().localMgr.saveCurrentBookId(book.id);
    DatabaseMgr().localMgr.touchBookLastOpened(book.id);
    //get recipes and set tags and ingredients names to book
    recipes = DatabaseMgr().localMgr.getRecipesFromBook(book.id);
    // get user access
    userAccess = DatabaseMgr().localMgr.getUserAccess(book.id) ?? AccessLevel.read;
    // refresh UI
    setState(() {});
  }

  Future<void> addNewBook() async {
    if (!DatabaseMgr().isCompatible) {
      ToastNotifier().showWarning(S.of(context).outdated_version_login_blocked);
      return;
    }
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

  void _checkPendingDeepLink() {
    final recipeId = DatabaseMgr().pendingDeepLinkRecipeId;
    if (recipeId == null) return;
    DatabaseMgr().pendingDeepLinkRecipeId = null;
    _openRecipeFromDeepLink(recipeId);
  }

  void _openRecipeFromDeepLink(String recipeId) {
    final book = DatabaseMgr().localMgr.findBookForRecipe(recipeId);
    if (book == null) {
      ToastNotifier().showWarning(S.of(context).deeplink_recipe_not_found);
      return;
    }
    setBookAsDefaultAndRefresh(book).then((_) {
      final recipe = DatabaseMgr().localMgr.getRecipe(recipeId);
      if (recipe != null && mounted) {
        Navigator.of(context).pushNamed("${RecipePage.route}/$recipeId", arguments: {'recipe': recipe});
      }
    });
  }

  Future<void> refreshData() async {
    await DatabaseMgr().remoteMgr.testConnexion();
    _log.fine("isOnline: ${DatabaseMgr().isOnline}");
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
          _log.fine('current book deleted, selecting first');
          selectedBook = books![0];
        } else {
          _log.info('no books remaining');
          selectedBook = null;
          return;
        }
      }
      // reload recipes
      recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
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
    
    final bool isUltraWide = Breakpoints.isUltraWide(context);
    final bool isWide = isUltraWide || Breakpoints.isWide(context);
    final AppUser? appUser = DatabaseMgr().localMgr.getUser();

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
        drawer: isWide ? null : homepageDrawer(appUser),
        onDrawerChanged: isWide ? null : (isOpened) async {
            if (isOpened) {
              await DatabaseMgr().remoteMgr.testConnexion();
              setState(() {});
            }
          },
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Theme.of(context).brightness == Brightness.dark
                  ? const AssetImage("assets/images/background.png")
                  : const AssetImage("assets/images/background_light.png"),
              fit: BoxFit.cover,
            )
          ),
          child: isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                // ── Sidebar ──────────────────────────────────────────
                Material(
                  color: ThemeMgr.getTheme(context)!.drawerTheme.backgroundColor!,
                  child: SizedBox(width: 280, child: appUser != null ? _sidebarContent(appUser, isWide: true) : const SizedBox()),
                ),
                VerticalDivider(width: 1, thickness: 1, color: ThemeMgr.getTheme(context)!.dividerColor),
                // ── Recipe list ───────────────────────────────────────
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: Theme.of(context).brightness == Brightness.dark
                            ? const AssetImage('assets/images/background.png')
                            : const AssetImage('assets/images/background_light.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(children: [
                      Positioned.fill(child: _buildMainContent(context, isWide: true, isUltraWide: isUltraWide)),
                      if (selectedBook != null && userAccess != AccessLevel.read && DatabaseMgr().isCompatible)
                        Positioned(
                          bottom: 16, right: 16,
                          child: FloatingActionButton(
                            heroTag: 'fab_add_recipe',
                            onPressed: _addRecipe,
                            child: const Icon(Icons.add),
                          ),
                        ),
                    ])
                  ),
                ),
                // ── Recipe panel (≥ 1200px) — fixed 440px so the list always has room ──
                if (isUltraWide) ...[
                  VerticalDivider(width: 1, thickness: 1, color: ThemeMgr.getTheme(context)!.dividerColor),
                  Expanded(
                    child: Stack(children: [
                      Positioned.fill(child: RecipePanelWidget(recipe: _panelRecipe)),
                      if (_panelRecipe != null && userAccess != AccessLevel.read && DatabaseMgr().isCompatible)
                        Positioned(
                          bottom: 16, right: 16,
                          child: FloatingActionButton(
                            heroTag: 'fab_edit_recipe',
                            onPressed: _editPanelRecipe,
                            child: const Icon(Icons.edit),
                          ),
                        ),
                    ]),
                  ),
                ],
              ])
            : _buildMainContent(context, isWide: false),
        ),
        floatingActionButton: (isUltraWide || selectedBook == null || userAccess == AccessLevel.read || !DatabaseMgr().isCompatible)
            ? null
            : FloatingActionButton(
                onPressed: _addRecipe,
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

  Widget _buildMainContent(BuildContext context, {required bool isWide, bool isUltraWide = false}) {
    return Column(
      children: [
        if (!DatabaseMgr().isCompatible)
          MaterialBanner(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            backgroundColor: const Color(0xFFE6A817),
            leading: const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white),
            content: Text(
              S.of(context).outdated_version_banner,
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFE6A817),
                ),
                onPressed: () async {
                  final serverUri = DatabaseMgr().localMgr.getServerUri();
                  if (serverUri == null) return;
                  final url = "$serverUri/apk/download";
                  if (kIsWeb) {
                    downloadFile(url);
                  } else {
                    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                icon: const FaIcon(FontAwesomeIcons.download, size: 14),
              ),
            ],
          ),
        Expanded(
          child: selectedBook == null
            ? ListTile(title: Text(S.of(context).book_choice))
            : RefreshIndicator(
                onRefresh: refreshData,
                child: Builder(
                  builder: (context) {
                    if (recipes != null && recipes!.isNotEmpty) {
                      List<Recipe> sortedData = List<Recipe>.from(recipes!);
                      if (_sortingMethod == "alphaDown") {
                        sortedData.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                      } else if (_sortingMethod == "alphaUp") {
                        sortedData.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                      } else if (_sortingMethod == "timeDown") {
                        sortedData.sort((a, b) => a.getTotalTime().compareTo(b.getTotalTime()));
                      } else if (_sortingMethod == "timeUp") {
                        sortedData.sort((a, b) => b.getTotalTime().compareTo(a.getTotalTime()));
                      } else if (_sortingMethod == "lastUpdatedDown") {
                        sortedData.sort((a, b) => b.lastUpdate!.compareTo(a.lastUpdate!));
                      } else if (_sortingMethod == "lastUpdatedUp") {
                        sortedData.sort((a, b) => a.lastUpdate!.compareTo(b.lastUpdate!));
                      }

                      final AppUser? user = DatabaseMgr().localMgr.getUser();
                      final List<Recipe> filteredData = sortedData.where((recipe) {
                        if (_mandatoryTags.isNotEmpty &&
                            !_mandatoryTags.every((tag) => recipe.tags.contains(tag.id))) return false;
                        if (_mandatoryIngredients.isNotEmpty) {
                          final names = List<String>.generate(recipe.recipeIngredients.length,
                              (i) => removeDiacritics(recipe.recipeIngredients[i].getName()).toLowerCase().trim());
                          if (!_mandatoryIngredients.every(
                              (ing) => names.contains(removeDiacritics(ing.toLowerCase().trim())))) return false;
                        }
                        if (_displayFavorites && !(user?.favoriteRecipes.contains(recipe.id) ?? false)) return false;
                        if (_time > 0) {
                          final total = recipe.getTotalTime();
                          if (_isTimeMax && total >= _time) return false;
                          if (!_isTimeMax && total <= _time) return false;
                        }
                        if (_research.isNotEmpty &&
                            !removeDiacritics(recipe.name.toLowerCase())
                                .contains(removeDiacritics(_research.toLowerCase()))) return false;
                        return true;
                      }).toList();

                      // On wide screens use a 2-column grid for card mode
                      if (!_isListed && isWide) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) => RecipeCardTile(
                            key: ValueKey(filteredData[index].id),
                            recipe: filteredData[index],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: filteredData.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredData.length) return const SizedBox(height: 8);
                          final recipe = filteredData[index];

                          void onTap() async {
                            if (isUltraWide) {
                              setState(() { _panelRecipe = recipe; });
                              return;
                            }
                            final navigator = Navigator.of(context);
                            final result = await navigator.pushNamed(
                                "${RecipePage.route}/${recipe.id}",
                                arguments: {'recipe': recipe});
                            if (!mounted) return;
                            if (result == "reloadRecipes") {
                              recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
                              setState(() {});
                            } else if (result == "reloadBooks") {
                              books = DatabaseMgr().localMgr.getUserBooks();
                              setState(() {});
                            }
                          }

                          if (_isListed) {
                            return RecipeListTile(
                              key: ValueKey(recipe.id),
                              recipe: recipe,
                              onTap: onTap,
                              onLongPress: DatabaseMgr().isCompatible ? () => _showCustomMenu(recipe) : null,
                              onTapDown: _storePosition,
                            );
                          } else {
                            return RecipeCardTile(key: ValueKey(recipe.id), recipe: recipe);
                          }
                        },
                      );
                    } else if (recipes != null) {
                      return ListTile(title: Text(S.of(context).no_recipe));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
        ),
      ],
    );
  }

  Future<void> _addRecipe() async {
    final navigator = Navigator.of(context);
    final name = await navigator.push<String>(
      MaterialPageRoute(builder: (_) => RecipeNamePage(currentName: "")),
    );
    if (!mounted || name == null) return;
    final newRecipeId = await DatabaseMgr().localMgr.addNewRecipe(name: name, bookId: selectedBook!.id);
    if (!mounted) return;
    await navigator.pushNamed("${RecipePage.route}/$newRecipeId", arguments: {
      'recipe': DatabaseMgr().localMgr.getRecipe(newRecipeId),
      'isNewRecipe': true,
    });
    if (!mounted) return;
    books = DatabaseMgr().localMgr.getUserBooks();
    final found = findBookFromId(selectedBook!.id);
    if (found != null) selectedBook = found;
    recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
    setState(() {});
  }

  Future<void> _editPanelRecipe() async {
    if (_panelRecipe == null) return;
    final navigator = Navigator.of(context);
    final result = await navigator.pushNamed(
      "${RecipePage.route}/${_panelRecipe!.id}",
      arguments: {'recipe': _panelRecipe, 'isEditMode': true},
    );
    if (!mounted) return;
    if (result == "reloadRecipes" || result == "reloadBooks") {
      final updated = DatabaseMgr().localMgr.getRecipe(_panelRecipe!.id);
      recipes = DatabaseMgr().localMgr.getRecipesFromBook(selectedBook!.id);
      setState(() { _panelRecipe = updated ?? _panelRecipe; });
    }
  }

  Drawer homepageDrawer(AppUser? appUser) {
    if (appUser == null) return const Drawer();
    return Drawer(child: _sidebarContent(appUser, isWide: false));
  }

  Widget _sidebarContent(AppUser appUser, {required bool isWide}) {
    Widget addButton = MyOutlinedButton(
        text: S.of(context).add_button,
        icon: FontAwesomeIcons.plus,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        onPressed: addNewBook
    );

    return Column(
        children: <Widget>[
          Stack(
            fit: StackFit.loose,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: ThemeMgr.getTheme(context)!.appBarTheme.backgroundColor,
                ),
                accountName: Text(
                  appUser.name,
                  style: ThemeMgr.getTheme(context)!.appBarTheme.titleTextStyle,
                ),
                accountEmail: Text(
                  appUser.email,
                  style: ThemeMgr.getTheme(context)!.appBarTheme.titleTextStyle!.copyWith(fontSize: 13),
                ),
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
              child: Builder(builder: (context) {
                final lastOpened = DatabaseMgr().localMgr.getBookLastOpened();
                final sortedBooks = List<Book>.from(books!)
                  ..sort((a, b) => (lastOpened[b.id] ?? 0).compareTo(lastOpened[a.id] ?? 0));
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  itemCount: sortedBooks.length + 1,
                  itemBuilder: (context, int index) {
                    return index < sortedBooks.length ?
                      ListTile(
                        key: UniqueKey(),
                        leading: FaIcon(sortedBooks[index].access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.own ? FontAwesomeIcons.book :
                                          sortedBooks[index].access[DatabaseMgr().localMgr.getUserId()] == AccessLevel.write ? CustomIcons.book_write :
                                            CustomIcons.book_read),
                        title: Text(sortedBooks[index].name),
                        textColor: selectedBook != null && selectedBook!.id == sortedBooks[index].id ? ThemeMgr.getTheme(context)!.colorScheme.primary : ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color,
                        iconColor: selectedBook != null && selectedBook!.id == sortedBooks[index].id ? ThemeMgr.getTheme(context)!.colorScheme.primary : ThemeMgr.getTheme(context)!.textTheme.bodyMedium!.color,
                        trailing: selectedBook != null && selectedBook!.id == sortedBooks[index].id ? CircularIconButton(
                          icon: FaIcon(FontAwesomeIcons.gear, color: ThemeMgr.getTheme(context)!.textTheme.bodyLarge!.color),
                          color: ThemeMgr.getTheme(context)!.cardColor,
                          onPressed: () {
                            Navigator.of(context).pushNamed("${BookSettingsPage.route}/${sortedBooks[index].id}", arguments: {
                              'book': sortedBooks[index]
                            }).then((value) async {
                              books = DatabaseMgr().localMgr.getUserBooks();
                              if (books != null) {
                                selectedBook = findBookFromId(selectedBook!.id);
                                if (selectedBook == null) {
                                  if (books!.isNotEmpty) {
                                    selectedBook = books![0];
                                  }
                                }
                                setState(() {});
                              }
                            });
                          },
                        ) : null,
                        onTap: () async {
                          setBookAsDefaultAndRefresh(sortedBooks[index]);
                          if (!isWide) Navigator.pop(context);
                        },
                      ) :
                      addButton;
                  },
                );
              }),
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
    );
  }
}