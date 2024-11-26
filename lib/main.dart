import 'package:cuicuisine/pages/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'database/database_mgr.dart';
import 'generated/l10n.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'pages/404.dart';
import 'pages/authentication/authentication_page.dart';
import 'pages/authentication/email_check_page.dart';
import 'pages/authentication/email_connexion.dart';
import 'pages/authentication/email_registration.dart';
import 'pages/authentication/remove_account.dart';
import 'pages/books/book_join_page.dart';
import 'pages/books/book_name_page.dart';
import 'pages/books/book_settings_page.dart';
import 'pages/general_settings_page.dart';
import 'pages/home_page.dart';
import 'pages/item_selector_page.dart';
import 'pages/recipes/ingredient_edition_page.dart';
import 'pages/recipes/new_tag_page.dart';
import 'pages/recipes/recipe_images_edition_page.dart';
import 'pages/recipes/recipe_ingredients_edition_page.dart';
import 'pages/recipes/recipe_name_page.dart';
import 'pages/recipes/recipe_page.dart';
import 'pages/recipes/recipe_step_edition_page.dart';
import 'pages/recipes/recipe_steps_edition_page.dart';
import 'pages/recipes/recipe_tag_edition_page.dart';
import 'pages/recipes/recipe_time_edition_page.dart';
import 'themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Disable landscape mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await DatabaseMgr().initialize();

  runApp(const Cuicuisine());
}

class Cuicuisine extends StatefulWidget {
  const Cuicuisine({super.key});

  @override
  State<Cuicuisine> createState() => _CuicuisineState();

  static _CuicuisineState? of(BuildContext context) => context.findAncestorStateOfType<_CuicuisineState>();
}

class _CuicuisineState extends State<Cuicuisine> {
  // Handle locale switch
  Locale? _locale;

  void changeLocale(String localeCode) {
    setState(() {
      _locale = S.delegate.supportedLocales.firstWhere((l) => l.languageCode == localeCode);
    });
  }

  String getLocaleCode() {
    return _locale!.languageCode;
  }

  @override
  void initState() {
    super.initState();

    String? localeCode = DatabaseMgr().localMgr.loadLocale();
    if (localeCode != null) {
      changeLocale(localeCode);
    }
    else {
      changeLocale("fr");
    }

    // load wakelock state
    bool? wakelockState = DatabaseMgr().localMgr.loadWakelock();
    if (wakelockState != null) {
      wakelockState ? WakelockPlus.enable() : WakelockPlus.disable();
    } else {
      DatabaseMgr().localMgr.saveWakelock(false);
    }
    print("Wakelock state: $wakelockState");

  }


  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DynamicTheme(
        themeCollection: setThemeCollection(context),
        defaultThemeId: AppThemes.Dark, // optional, default id is 0
        builder: (context, theme) {
          return MaterialApp(
            theme: theme,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale!.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            locale: _locale,
            initialRoute: LogInPage.route,
            routes: {
              LogInPage.route: (ctx) => LogInPage(),
              EmailCheck.route: (ctx) => const EmailCheck(),
              // EmailConnexion.route: (ctx) => const EmailConnexion(),
              // EmailRegistration.route: (ctx) => EmailRegistration(),
              // ForgottenPasswordPage.route: (ctx) => ForgottenPasswordPage(),
              HomePage.route: (ctx) => HomePage(),
              GeneralSettingsPage.route: (ctx) => GeneralSettingsPage(),
              RemoveAccountPage.route: (ctx) => const RemoveAccountPage(),
              BookNamePage.route: (ctx) => const BookNamePage(),
              ItemSelector.route: (ctx) => const ItemSelector(),
              PageNotFound.route: (ctx) => const PageNotFound(),
              TestPage.route: (ctx) => TestPage()
            },
            onGenerateRoute: (RouteSettings settings) {
              // navigate to email connexion page
              if (settings.name!.contains(EmailConnexion.route)) {
                return MaterialPageRoute(builder: (context) => const EmailConnexion(), settings: settings);
              }
              // navigate to email connexion page
              else if (settings.name!.contains(EmailRegistration.route)) {
                return MaterialPageRoute(builder: (context) => EmailRegistration(), settings: settings);
              }
              // navigate to recipe page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 4) {
                return MaterialPageRoute(builder: (context) => RecipePage(), settings: settings);
              }
              // navigate to recipe name edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'rename') {
                return MaterialPageRoute(builder: (context) => const RecipeNamePage(), settings: settings);
              }
              // // navigate to recipe image edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'images') {
                return MaterialPageRoute(builder: (context) => const RecipeImagesEditionPage(), settings: settings);
              }
              // navigate to recipe time edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'time') {
                return MaterialPageRoute(builder: (context) => const RecipeTimeEditionPage(), settings: settings);
              }
              // navigate to recipe tags edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'tags') {
                return MaterialPageRoute(builder: (context) => const RecipeTagEditionPage(), settings: settings);
              }
              // navigate to recipe tags edition -> new tag page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 7
                  && settings.name!.split('/')[5] == 'tags'
                  && settings.name!.split('/').last == 'new') {
                return MaterialPageRoute(builder: (context) => const NewTagPage(), settings: settings);
              }
              // navigate to recipe ingredients edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'ingredients') {
                return MaterialPageRoute(builder: (context) => const RecipeIngredientsEditionPage(), settings: settings);
              }
              // navigate to specific ingredient edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 7
                  && settings.name!.split('/')[5] == 'ingredients'
                  && settings.name!.split('/').last == 'edition') {
                return MaterialPageRoute(builder: (context) => const IngredientEditionPage(), settings: settings);
              }
              // navigate to recipe steps edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'steps') {
                return MaterialPageRoute(builder: (context) => const RecipeStepsEditionPage(), settings: settings);
              }
              // navigate to specific step edition page
              else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 7
                  && settings.name!.split('/')[5] == 'steps'
                  && int.tryParse(settings.name!.split('/').last) != null) {
                return MaterialPageRoute(builder: (context) => const StepEditionPage(), settings: settings);
              }

              // navigate to book settings page
              else if (settings.name!.contains(BookSettingsPage.route) && settings.name!.split('/').length == 4) {
                return MaterialPageRoute(builder: (context) => const BookSettingsPage(), settings: settings);
              }

              // navigate to join book page
              else if (settings.name!.contains(BookJoinPage.route)) {
                return MaterialPageRoute(builder: (context) => const BookJoinPage(), settings: settings);
              }

              else {
                //404
                return MaterialPageRoute(builder: (context) => const PageNotFound());
              }
            },
          );
        }
    );
  }
}
