import 'package:pantrypal/screens/home.dart';
import 'package:pantrypal/screens/landing.dart';
import 'package:pantrypal/screens/login.dart';
import 'package:pantrypal/screens/signup.dart';
import 'package:pantrypal/screens/forgotPassword.dart';
import 'package:pantrypal/screens/verification.dart';
import 'package:pantrypal/utils/AuthProvider.dart';
import 'package:pantrypal/utils/IngredientModel.dart';
import 'package:pantrypal/utils/UserProvider.dart';
import 'package:pantrypal/utils/UserPreference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/User.dart';
import 'utils/RouteNames.dart';

void main() {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // comment/uncomment this v line depending on if you want to sign in/out on reload
    // UserPreference().removeUser();
    Future<User> getUserData() => UserPreference().getUser();

    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => IngredientModel()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider())
        ],
        child:
            // MaterialApp is the main app being run. There should only exist one for
            // each project.
            MaterialApp(
                title: 'Pantry Pal',

                // The ThemeData allows our widgets to use default colors. Change this
                // depending on how we want the project to look.
                theme: ThemeData(
                  // PrimarySwatch and color mostly deal with how text vs. buttons are colored.
                  primarySwatch: Colors.green,
                  primaryColor: Colors.green,
                  accentColor: Colors.grey,
                ),

                // Start the app on the landing page. This could be made conditional
                // depending on the state of the login.
                // initialRoute: RouteName.HOME,
                home: FutureBuilder(
                    future: getUserData(),
                    builder: (context, AsyncSnapshot<User> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                          return CircularProgressIndicator();
                        default:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else if ((snapshot.data?.token ?? 'null') == 'null') {
                            UserPreference().removeUser();
                            return Landing();
                          } else {
                            var auth = Provider.of<AuthProvider>(context,
                                listen: false);
                            var user = Provider.of<UserProvider>(context,
                                listen: false);

                            auth.loggedInStatus = Status.LoggedIn;
                            auth.registeredStatus = Status.Registered;
                            user.initializeUser(snapshot.data!);
                            auth.verificationStatus = user.user.verified
                                ? Status.Verified
                                : Status.NotVerified;
                          }
                          return Home();
                      }
                    }),

                // home: loginFuture,
                // Routes are used for app and web navigation. For example,
                // hitting the back button returns to the previous route.
                routes: {
              RouteName.LANDING: (context) => Landing(),
              RouteName.SIGNUP: (context) => Signup(),
              RouteName.LOGIN: (context) => Login(),
              RouteName.FORGOTPASSWORD: (context) => ForgotPassword(),
              RouteName.HOME: (context) => Home(),
              RouteName.VERIFICATION: (context) => Verification()
            }));
  }
}
