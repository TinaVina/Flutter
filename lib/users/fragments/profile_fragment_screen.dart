import 'package:flutter/material.dart';
import 'package:furniture_store_app/users/authentication/login_screen.dart';
import 'package:furniture_store_app/users/userPreferences/current_user.dart';
import 'package:furniture_store_app/users/userPreferences/user_preferences.dart';
import 'package:get/get.dart';

class ProfileFragmentScreen extends StatelessWidget
{
  final CurrentUser _currentUser= Get.put(CurrentUser());//access the info of the already logged in user

  signOutUser()async //wait for response
  {
    var resultResponse= await Get.dialog(
      AlertDialog(
       backgroundColor: Colors.white,
        title: Text(
          "Sign out",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,


          ),
        ),
        content: Text(
          "Are you sure you want to sign out?"
        ),
        actions: [
         TextButton(
             onPressed: (){
               Get.back(
                 //close dialog box and do nothing
               );
             },
             child: const Text(
               "No",
               style: TextStyle(
                 color: Colors.black,
               ),
             )
         ),
          TextButton(
              onPressed: (){
                Get.back(
                  result: "loggedOut"
                );
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Colors.black,
                ),
              )
          ),
        ],
      ),
    );
    if(resultResponse == "loggedOut")//yes button is clicked
    {
      //remove user data from phone local storage
      RemeberUserPref.removeUserData().then((value)
      {//in the end send user to Login screen
        Get.off(LoginScreen());
      });
    }
  }

  Widget userInfoItemProfile(IconData iconData, String userData)
  {
    return Container
      (
      decoration: BoxDecoration
        (
        borderRadius: BorderRadius.circular(20),
        color: Colors.blueGrey,
      ),
        padding: const EdgeInsets.symmetric
          (
          horizontal: 10,
          vertical: 15,
        ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 25,
            color: Colors.white,

          ),
          const SizedBox(width: 20,),
          Text(
            userData,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.white,
              
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView
      (
      children: [
        Center(
          child: Image.asset(
            "images/profileicon.png",
            width: 250,
          ),
        ),
        const SizedBox(height: 25,),

        userInfoItemProfile(Icons.account_circle_sharp, _currentUser.user.user_name),
        const SizedBox(height: 20,),
        userInfoItemProfile(Icons.mail, _currentUser.user.user_email),
        const SizedBox(height: 20,),

        Center(
          child: Material(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: (){
                signOutUser();
              },
              borderRadius: BorderRadius.circular(25),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,

                ),
                child: Text(
                  "Sign out",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}
