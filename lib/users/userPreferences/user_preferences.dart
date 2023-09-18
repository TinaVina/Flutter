import 'dart:convert';

import 'package:furniture_store_app/users/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemeberUserPref
{
  //remeber user info
  static Future<void> storeUserInfo(User userInfo) async
  {
    SharedPreferences preferences= await SharedPreferences.getInstance();
    String userJsonData= jsonEncode(userInfo.toJson());
    await preferences.setString("currentUser", userJsonData);

  }

  static Future<User?> readUserInfo() async
  {
    User? currentUserInfo;
    SharedPreferences preferences= await SharedPreferences.getInstance();
    String? userInfo= preferences.getString("currentUser");//data in json format
    if(userInfo!=null)
    {
      Map<String, dynamic> userDataMap= jsonDecode(userInfo);
      currentUserInfo= User.fromJson(userDataMap);
    }

    return currentUserInfo;
  }

  static Future<void> removeUserData()async //once the user clicks sign out
  {
    SharedPreferences preferences= await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
  }

}