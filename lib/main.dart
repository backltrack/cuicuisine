import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:cuicuisine/pages/account/account_page.dart';
import 'package:cuicuisine/pages/account/update_password.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:toastification/toastification.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_size/window_size.dart';

import 'database/database_mgr.dart';
import 'utilities/logger.dart';
import 'generated/l10n.dart';
import 'package:dynamic_themes/dynamic_themes.dart';
import 'pages/404.dart';
import 'pages/authentication/authentication_page.dart';
import 'pages/authentication/email_check_page.dart';
import 'pages/authentication/email_connexion.dart';
import 'pages/authentication/email_registration.dart';
import 'pages/authentication/onboarding_page.dart';
import 'pages/account/remove_account.dart';
import 'pages/authentication/forgotten_password.dart';
import 'pages/books/book_join_page.dart';
import 'pages/books/book_name_page.dart';
import 'pages/books/book_settings_page.dart';
import 'pages/books/book_share_page.dart';
import 'pages/books/book_tags_edition_page.dart';
import 'pages/settings/general_settings_page.dart';
import 'pages/home_page.dart';
import 'pages/item_selector_page.dart';
import 'pages/recipes/ingredient_edition_page.dart';
import 'pages/recipes/book_ingredient_edition_page.dart';
import 'pages/recipes/new_tag_page.dart';
import 'pages/recipes/recipe_images_edition_page.dart';
import 'pages/recipes/recipe_ingredients_edition_page.dart';
import 'pages/recipes/recipe_page.dart';
import 'pages/recipes/recipe_step_edition_page.dart';
import 'pages/recipes/recipe_steps_edition_page.dart';
import 'pages/recipes/recipe_tag_edition_page.dart';
import 'pages/recipes/recipe_time_edition_page.dart';
import 'pages/settings/synchronization_status_page.dart';
import 'themes/themes.dart';

void main() async {
  setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  // Disable landscape mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  HttpOverrides.global = MyHttpOverrides();

  if (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS) {
    setWindowMinSize(const Size(400, 500));
  }

  await DatabaseMgr().initialize();

  runApp(const Cuicuisine());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class Cuicuisine extends StatefulWidget {
  const Cuicuisine({super.key});

  @override
  State<Cuicuisine> createState() => _CuicuisineState();

  static _CuicuisineState? of(BuildContext context) => context.findAncestorStateOfType<_CuicuisineState>();
}

class _CuicuisineState extends State<Cuicuisine> {
  // Handle locale switch
  Locale? _locale;
  StreamSubscription<Uri>? _deepLinkSub;

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
    if (!kIsWeb) {
      bool? wakelockState = DatabaseMgr().localMgr.loadWakelock();
      if (wakelockState != null) {
        wakelockState ? WakelockPlus.enable() : WakelockPlus.disable();
      } else {
        DatabaseMgr().localMgr.saveWakelock(false);
      }
    }

    _initDeepLinks();
  }

  void _initDeepLinks() async {
    final appLinks = AppLinks();
    // Cold start: link that launched the app
    final initial = await appLinks.getInitialLink();
    if (initial != null) _handleDeepLink(initial);
    // Hot start: link received while app is running
    _deepLinkSub = appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme != 'cuicuisine' || uri.host != 'recipe') return;
    final recipeId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    if (recipeId == null || recipeId.isEmpty) return;
    DatabaseMgr().pendingDeepLinkRecipeId = recipeId;
    if (DatabaseMgr().localMgr.getUser() != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(HomePage.route, (r) => false);
    }
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    if (kIsWeb) {
      WakelockPlus.disable();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DynamicTheme(
        themeCollection: setThemeCollection(context),
        defaultThemeId: AppThemes.Dark, // optional, default id is 0
        builder: (context, theme) {
          return ToastificationWrapper(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              theme: theme,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FlutterQuillLocalizations.delegate,
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
                EmailConnexion.route: (ctx) => const EmailConnexion(),
                EmailRegistration.route: (ctx) => EmailRegistration(),
                OnboardingPage.route: (ctx) => const OnboardingPage(),
                ForgottenPasswordPage.route: (ctx) => const ForgottenPasswordPage(),
                HomePage.route: (ctx) => HomePage(),
                GeneralSettingsPage.route: (ctx) => const GeneralSettingsPage(),
                SynchronizationStatusPage.route: (ctx) => const SynchronizationStatusPage(),
                AccountPage.route: (ctx) => const AccountPage(),
                UpdatePassword.route: (ctx) => const UpdatePassword(),
                RemoveAccountPage.route: (ctx) => const RemoveAccountPage(),
                BookNamePage.route: (ctx) => const BookNamePage(),
                ItemSelector.route: (ctx) => const ItemSelector(),
                PageNotFound.route: (ctx) => const PageNotFound()
              },
              onGenerateRoute: (RouteSettings settings) {
                // navigate to recipe page
                if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 4) {
                  return MaterialPageRoute(builder: (context) => RecipePage(), settings: settings);
                }
                // navigate to recipe name edition page
                // else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 6 && settings.name!.split('/').last == 'rename') {
                //   return MaterialPageRoute(builder: (context) => const RecipeNamePage(), settings: settings);
                // }
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
                // navigate to book ingredient edition page
                else if (settings.name!.contains(RecipePage.route) && settings.name!.split('/').length == 8
                    && settings.name!.split('/')[5] == 'ingredients'
                    && settings.name!.split('/')[6] == 'edition'
                    && settings.name!.split('/').last == 'book_ingredient') {
                  return MaterialPageRoute(builder: (context) => const BookIngredientEditionPage(), settings: settings);
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

                // navigate to book tags edition page
                else if (settings.name!.contains(BookSettingsPage.route) && settings.name!.split('/').length == 5 && settings.name!.split('/').last == 'tags') {
                  return MaterialPageRoute(builder: (context) => const BookTagsEditionPage(), settings: settings);
                }

                // navigate to book share page
                else if (settings.name!.contains(BookSharePage.route) && settings.name!.split('/').length == 4) {
                  return MaterialPageRoute(builder: (context) => const BookSharePage(), settings: settings);
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
            )
          );
        }
    );
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
