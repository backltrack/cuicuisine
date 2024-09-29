import 'package:cuicuisine/widgets/core_widgets/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../generated/l10n.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/animated_icon_button.dart';
import '../../widgets/core_widgets/social_button.dart';
import '../home_page.dart';
import 'email_connexion.dart';

class LogInPage extends StatefulWidget {
  static const String route = '/';
  static AppUser? appUser;

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> with TickerProviderStateMixin {

  bool _connexionTested = false;

  AnimationController? controllerTranslation;
  Animation<double>? animationTranslation;

  AnimationController? controllerOpacity;
  Animation<double>? animationOpacity;

  final TextEditingController _serverTextEditingController = TextEditingController();
  final FocusNode _serverFocusNode = FocusNode();
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();

    init();

    // Loading screen animations : translation
    controllerTranslation = AnimationController(
        duration: const Duration(seconds: 1), vsync: this)..addListener(() =>
        setState(() {}));
    animationTranslation = Tween(begin: 0.0, end: -200.0).animate(CurvedAnimation(parent: controllerTranslation!, curve: Curves.easeInCubic));

    // Loading screen animations : opacity
    controllerOpacity = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animationOpacity = Tween(begin: 0.0, end: 1.0).animate(controllerOpacity!);

    _serverTextEditingController.text = DatabaseMgr().localMgr.getServerUri() ?? "";

  }

  void tryOfflineConnexion() {
    AppUser? user =  DatabaseMgr().localMgr.getUser();
      if (user != null) {
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (Route<dynamic> route) => false);
      }
      else {
        Fluttertoast.showToast(msg: S.of(context).connexion_needed);
      }
  }

  void init() async {
    await DatabaseMgr().remoteMgr.testConnexion();
    if (DatabaseMgr().isOnline) {
      AppUser? user = await DatabaseMgr().remoteMgr.tryReconnect();
      if (user != null) {
        print('synch + goto homepage');
        print("Pending operations in queue: ${DatabaseMgr().localMgr.getQueueLength()}");
        print("Operations: ${DatabaseMgr().localMgr.getOperationLength()}");
        // synchronize
        await DatabaseMgr().synchronization.sync();
        // goto home page
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (Route<dynamic> route) => false);
        // if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(TestPage.route, (Route<dynamic> route) => false);
      }
      else {
        print('need to register');
        // need to register or reconnect
      }
    }
    else {
      AppUser? user =  DatabaseMgr().localMgr.getUser();
      if (user != null) {
        bool? goOffline = await showAlertDialog(
          context: context,
          title: S.of(context).offline_alert_title,
          description: Text(S.of(context).offline_alert_description)
        );
        if (goOffline != null && goOffline) {
          print('offline switch to local mode');
          tryOfflineConnexion();
        } 
        else {
          Fluttertoast.showToast(msg: S.of(context).offline_refused_toast);
        }
      }
    }

    setState(() {
      _connexionTested = true;
      controllerTranslation!.forward();
      controllerOpacity!.forward();
    });
  }

  @override
  void dispose() {
    if (controllerOpacity != null) controllerOpacity!.dispose();
    if (controllerTranslation != null) controllerTranslation!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _connexionTested ?
      Container(
        width: double.infinity,
        height: double.infinity,
        color: ThemeMgr.getTheme(context)!.cardColor,
        child: Stack(
          children: [
            Center(
                child: Transform.translate(
                    offset: Offset(0, animationTranslation!.value),
                    child: CircleAvatar(
                        radius: 128 / 2 + 36,
                        backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.background,
                        child: Image.asset('assets/icons/splash_icon.png', width: 128)
                    )
                )
            ),
            SizedBox(
                width: double.infinity,
                child: FadeTransition(
                  opacity: animationOpacity!,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: (48 + 16) * 2),

                      // EMAIL method
                      SocialButton(
                        onPressed: DatabaseMgr().isOnline ? () async {
                          Navigator.pushNamed(context, EmailConnexion.route);
                        } : null,
                        child: const FaIcon(
                          FontAwesomeIcons.envelope
                        ),
                      ),
                    ],
                  ),
                )
            ),
            Container(
              alignment: Alignment.bottomLeft,
              margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget> [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(12),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DatabaseMgr().isOnline ? Colors.green : Colors.red
                        )
                      ),
                      Text(
                        DatabaseMgr().isOnline ? "Server online" : "Server offline",
                        style: ThemeMgr.getTheme(context)!.textTheme.bodyLarge,
                      )
                    ],
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.gear),
                    color: !_showSettings ? Colors.white70 : ThemeMgr.getTheme(context)!.primaryColor,
                    onPressed: () {
                      setState(() {
                        _showSettings = !_showSettings;
                      });
                    },
                  )
                ],
              ),
            ),

            !_showSettings ? const SizedBox() : Container(
              alignment: Alignment.bottomLeft,
              margin: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: _serverFocusNode.hasFocus ? MediaQuery.of(context).viewInsets.bottom : 64),
              child: Material(
                color: Colors.white10,
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                textStyle: ThemeMgr.getTheme(context)!.textTheme.bodyLarge,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(S.of(context).general_settings_server),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _serverTextEditingController,
                        focusNode: _serverFocusNode,
                        onTap: () {
                          setState(() {
                            _serverFocusNode.requestFocus();
                          });
                        },
                        onTapOutside: (_) {
                          setState(() {
                            _serverFocusNode.unfocus();
                          });
                        },
                      )
                    ),
                    AnimatedIconButton(
                      icon: const Icon(FontAwesomeIcons.arrowsRotate),
                      onPressed: () async {
                        bool isUriWorking = await DatabaseMgr().remoteMgr.setServer(_serverTextEditingController.text);
                        setState(() {});

                        if (isUriWorking) {
                          tryOfflineConnexion();
                        }
                        else {
                          _serverTextEditingController.text = DatabaseMgr().localMgr.getServerUri() ?? "";
                        }
                      },
                    )
                  ]
                )
              )
            )
          ],
        )
      ) :
      // connexion not tested
      const LoadingScreen();
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeMgr.getTheme(context)!.cardColor,
      child: Center(
        child: CircleAvatar(
          radius: 128 / 2 + 36,
          backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.background,
          child: Image.asset('assets/icons/splash_icon.png', width: 128)
        ),
      ),
    );
  }
}
