import 'package:flutter/material.dart';
import 'package:furniture_store_app/users/authentication/login_screen.dart';
import 'package:furniture_store_app/users/fragments/dashboard_of_fragments.dart';
import 'package:furniture_store_app/users/userPreferences/user_preferences.dart';
import 'package:get/get.dart';

void main()
{
  WidgetsFlutterBinding.ensureInitialized();//ensure we don't get a white screen when launching
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Furntsy', // Application name
      debugShowCheckedModeBanner: false, //don't show debug banner on App
      theme: ThemeData(

        primarySwatch: Colors.indigo,
      ),
      home: FutureBuilder(
        future: RemeberUserPref.readUserInfo(),//it remembers the user preferences
        builder: (context, dataSnapShot)
        {
          //if the user is already logged in successfully it will send him to the dashboard right away.
          if(dataSnapShot.data == null)
          {
            return LoginScreen();
          }
          else
          {
            return DashboardOfFragments();
          }
        },
      ),
    );
  }
}


