
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doodeluser/grocerry_kit/announcements.dart';
import 'package:doodeluser/grocerry_kit/maintenance_page.dart';
import 'package:doodeluser/providers/collection_names.dart';
import 'package:doodeluser/providers/search_results.dart';
import 'package:doodeluser/services/app_navigation_service.dart';
import 'package:doodeluser/services/preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'const.dart';
import 'grocerry_kit/store_package/stores_list_screen.dart';
import 'providers/cart.dart';
import 'providers/category.dart';
import 'providers/product.dart';
import 'providers/store.dart';
import 'providers/user.dart';
import 'services/new_version_service.dart';
import 'ui/login_page.dart';
import 'utils/material_color.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

double devHeight;
double devWidth;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const kSnackBarDuration = Duration(seconds: 2);
const String _exampleDsn = 'https://a7c8bb966d2b4140b46a3ac3a127f07f@o1233405.ingest.sentry.io/6382570';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Preferences.init();
  NewVersionCheckerService.init();
  Stripe.publishableKey = stripeLivePublicKey;
  // Stripe.publishableKey = stripeTestPublicKey;
  await Stripe.instance.applySettings();
  await SentryFlutter.init(
        (options) {
      options.dsn = _exampleDsn;
      options.tracesSampleRate = 1.0;
    },
  appRunner: () => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Store(),
        ),
        ChangeNotifierProvider(
          create: (_) => Category(),
        ),
        ChangeNotifierProvider(
          create: (_) => Product(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchResults(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: AppNavigatorService.navigatorKey,
        title: 'Grocery App',
        theme: ThemeData(
          primaryColor: MyColors.appColor,
          brightness: Brightness.light,
          primarySwatch: MyColors.appColor,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              primary: Color(0xff0644e3),
              textStyle: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),

        builder: (BuildContext context, Widget child) {
          return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(context).textScaleFactor < 1
                      ? MediaQuery.of(context).textScaleFactor
                      : 1),
              child: child);
        },
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case 'signInPage':
              return MaterialPageRoute(builder: (_) => LoginPage());
            case '/StoresList':
              return MaterialPageRoute(builder: (_) => StoresListPage());
            case '/Announcements':
              return MaterialPageRoute(builder: (_) => Announcements());
            case '/MaintenencePage':
              return MaterialPageRoute(builder: (_) => MaintenancePage());
            case '/':
            default:
              return MaterialPageRoute(builder: (_) => LoginPage());
          }
        },
      ),
    );
  }
}
