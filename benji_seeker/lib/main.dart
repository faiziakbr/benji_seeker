import 'package:benji_seeker/pages/PhotoViewPage.dart';
import 'package:benji_seeker/pages/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';

import 'constants/MyColors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    kNotificationDuration = const Duration(seconds: 3);
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  static Map<int, Color> color = {
    50: Color.fromRGBO(67, 162, 54, .1),
    100: Color.fromRGBO(67, 162, 54, .2),
    200: Color.fromRGBO(67, 162, 54, .3),
    300: Color.fromRGBO(67, 162, 54, .4),
    400: Color.fromRGBO(67, 162, 54, .5),
    500: Color.fromRGBO(67, 162, 54, .6),
    600: Color.fromRGBO(67, 162, 54, .7),
    700: Color.fromRGBO(67, 162, 54, .8),
    800: Color.fromRGBO(67, 162, 54, .9),
    900: Color.fromRGBO(67, 162, 54, 1),
  };

  //+12025550150
  //+11223334444
  //+12333444555
  //+17203391672
  //+13477974446
  //+13155352624
  //+13155352623
  //+13477974445
  //+11779169467

  //provider
  //+18888822222
  //+19386661770
  //+13328883090

  MaterialColor colorCustom = MaterialColor(0xFF43A236, color);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus.unfocus();
          }
        },
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'benji',
          builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaleFactor: 1.0),
              child: child,
            );
          },
          theme: ThemeData(
            primarySwatch: colorCustom,
            accentColor: accentColor,
          ),
          home: SplashScreen(),
        ),
      ),
    );
  }
}
