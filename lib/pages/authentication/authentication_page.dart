import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../database/database_mgr.dart';
import '../../models/data_model.dart';
import '../../themes/theme_mgr.dart';
import '../../widgets/core_widgets/circular_button.dart';
import '../../widgets/core_widgets/my_icon_button.dart';
import '../../widgets/core_widgets/social_button.dart';
// import '../home_page.dart';
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


    // DatabaseMgr().remoteMgr.tryReconnect();

    // Firebase auth event
    // auth.authStateChanges()
    //     .listen((User? user) async {
    //       if (user == null) {
    //         print('User is currently signed out!');
    //         if (!_connexionTested) {
    //           if (this.mounted) {
    //             setState(() {
    //               _connexionTested = true;
    //             });
    //           }
    //         }
    //       } else {
    //         var fireUser = auth.currentUser;
    //         if (fireUser != null) {
    //           // check if display name not null (in case of email account creation), else : wait until
    //           int counter = 50;
    //           if (fireUser.displayName == null) {
    //             while (counter > 0 && fireUser != null && fireUser.displayName == null) {
    //               fireUser = auth.currentUser;
    //               await Future.delayed(const Duration(milliseconds: 100));
    //               counter--;
    //               print("waiting...");
    //             }
    //           }
    //           if (counter == 0) {
    //             print("Timeout");
    //           }
    //           else {
    //             // fireUser filled: ready to connect or create account
    //             // check Hive current user
    //             AppUser? appUser = DatabaseMgr().hiveConnector.getUser();
    //             if (appUser != null && appUser.firebaseId == fireUser!.id) {
    //               // already loaded, try to sync Hive
    //               bool serverConnected = await DatabaseMgr().mongoConnector.testServerAccess();
    //               if (serverConnected) {
    //                 await DatabaseMgr().synchronization.syncAll();
    //               }
    //               else {
    //                 print('timeout, offline');
    //               }
    //               // goto HomePage
    //               if (this.mounted) Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (Route<dynamic> route) => false);
    //             }
    //             else {
    //               // Check internet connexion

    //               // Need to check MongoDB user inexistance then sync user
    //               bool existance = await DatabaseMgr().mongoConnector.userExsits(fireUser!.id);
    //               AppUser appUser;
    //               if (existance) {
    //                 // retrieve user
    //                 appUser = await DatabaseMgr().mongoConnector.fetchUser(fireUser.id);
    //               }
    //               else {
    //                 // create user
    //                 appUser = await DatabaseMgr().mongoConnector.createUser(AppUser(firebaseId: fireUser.id, name: fireUser.displayName!, email: fireUser.email!));
    //               }
    //               // clear Hive
    //               DatabaseMgr().hiveConnector.clearAll();
    //               // update hive data
    //               DatabaseMgr().hiveConnector.setUser(appUser);
    //               await DatabaseMgr().synchronization.fetchAll();
    //               // goto HomePage
    //               if (this.mounted) Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (Route<dynamic> route) => false);
    //             }
    //           }
    //         }
    //       }
    //     });
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
      print('offline switch to local mode');
      AppUser? user =  DatabaseMgr().localMgr.getUser();
      if (user != null) {        
        print("Start offline");
        print("Pending operations : ${DatabaseMgr().localMgr.getQueueLength()}");
        print("Operations: ${DatabaseMgr().localMgr.getOperationLength()}");
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(HomePage.route, (Route<dynamic> route) => false);
      }
      else {
        print("need internet connexion for registration");
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
                        child: Image.asset('assets/icons/splash_icon.png', width: 128),
                        radius: 128 / 2 + 36,
                        backgroundColor: ThemeMgr.getTheme(context)!.colorScheme.background
                    )
                )
            ),
            Container(
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
                        child: const FaIcon(
                          FontAwesomeIcons.envelope
                        ),
                        onPressed: () async {
                          Navigator.pushNamed(context, EmailConnexion.route);
                        },
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
                    color: Colors.white70,
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        )
      ) :
      // connexion not tested
      LoadingScreen();
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

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
