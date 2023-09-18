import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/admin/admin_login.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/authentication/signup_screen.dart';
import 'package:furniture_store_app/users/fragments/dashboard_of_fragments.dart';
import 'package:furniture_store_app/users/model/user.dart';
import 'package:furniture_store_app/users/userPreferences/user_preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget
{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  var formKey=GlobalKey<FormState>();
  var emailController= TextEditingController();
  var passwordController= TextEditingController();
  var isObsecure=true.obs;

  loginUserNow() async //waiting for a response
  {
    try
    {
      var res= await http.post
        (
          Uri.parse(API.login),
          body:
          {
            "user_email": emailController.text.trim(),
            "user_password": passwordController.text.trim(),
          }
      );

      if(res.statusCode==200)
      {
        var resBodyOfLogin=jsonDecode(res.body);
        if(resBodyOfLogin['success']== true)
        {
          Fluttertoast.showToast(msg: "You are logged in.");

          User userInfo= User.fromJson(resBodyOfLogin["userData"]);

          await RemeberUserPref.storeUserInfo(userInfo);

          Get.to(DashboardOfFragments());
        }
        else
        {
          Fluttertoast.showToast(msg: "Email or password incorrect.\nTry again!");
        }
      }
    }
    catch(e)
    {
      print("Error : "+ e.toString());
    }
  }

  @override
  Widget build(BuildContext context)

  {
    return Scaffold(
     backgroundColor: Colors.lightBlue.shade200,


      body: (LayoutBuilder
        (
        builder: (context, cons)
        {
          return ConstrainedBox
            (
            constraints: BoxConstraints
              (
              minHeight: cons.maxHeight
            ),
            child: SingleChildScrollView
              (
              child: Column
                (children:
              [ //login screen header
                SizedBox
                  (
                  width: MediaQuery.of(context).size.width, // adjust to the size of the screen
                  height:220,
                  child: Image.asset
                    (
                      "images/furntsy_home_1.png",
                  ),
                ),

                    const SizedBox(height: 25,),
                    //login form
                Padding(
                  padding: const EdgeInsets.fromLTRB(30,20,30,5),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container //border around the email and password input
                      (
                      decoration:  const BoxDecoration
                        (
                       gradient: LinearGradient(
                         colors: [
                           Colors.indigo,
                           Colors.cyan,
                         ],
                       ),
                        borderRadius: BorderRadius.all
                          (
                          Radius.circular(30),

                        ),
                        boxShadow:
                        [
                          BoxShadow
                            (
                            blurRadius:8 ,
                            color: Colors.indigo,
                            offset: Offset(0,-3),

                          ),
                        ],
                      ),

                      child: Column
                        (

                        children:
                        [
                          Form
                            (
                            key: formKey,

                            child: Column
                              (
                              children:
                              [
                                 const SizedBox(height: 25, ),
                                TextFormField //input from User for email
                                  (
                                  controller: emailController,
                                  validator: (val)=> val == "" ? "Please write your email" : null , //checks whether the user has inputed an email, if not writes out validation message
                                  decoration: InputDecoration
                                    (
                                    prefixIcon:  const Icon
                                      (
                                      Icons.email,
                                      color: Colors.white,

                                    ),
                                    hintText: "email",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide
                                        (
                                        color: Colors.white,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide
                                        (
                                        color: Colors.white,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide
                                        (
                                        color: Colors.white,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: const BorderSide
                                        (
                                        color: Colors.white,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric
                                      (
                                      horizontal:17,
                                      vertical: 10,
                                    ),
                                    fillColor: Colors.white38,
                                    filled: true,
                                  ),
                                ),

                                const SizedBox(height: 15,),
                               Obx
                                 (
                                   ()=> TextFormField //input from User for password
                                     (
                                     obscureText:  isObsecure.value,//writes the password in dots/stars, more secure
                                     controller: passwordController,
                                     validator: (val)=> val == "" ? "Please write your password" : null , //checks whether the user has inputed an password, if not writes out validation message
                                     decoration: InputDecoration
                                       (
                                       prefixIcon:  const Icon
                                         (
                                         Icons.vpn_key_sharp,
                                         color: Colors.white,

                                       ),
                                       suffixIcon: Obx
                                         (
                                             ()=>GestureDetector
                                           (
                                           onTap: ()
                                           { //when u tap on it it will display the text in it
                                             isObsecure.value= !isObsecure.value;
                                           },
                                           child: Icon
                                             ( //for the password, if it's true we want it the closed eye and if false the icon eye opened
                                             isObsecure.value? Icons.visibility_off: Icons.visibility,
                                           ),
                                         ),
                                       ),
                                       hintText: "password",
                                       border: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(30),
                                         borderSide: const BorderSide
                                           (
                                           color: Colors.white,
                                         ),
                                       ),
                                       enabledBorder: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(30),
                                         borderSide: const BorderSide
                                           (
                                           color: Colors.white,
                                         ),
                                       ),
                                       focusedBorder: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(30),
                                         borderSide: const BorderSide
                                           (
                                           color: Colors.white,
                                         ),
                                       ),
                                       disabledBorder: OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(30),
                                         borderSide: const BorderSide
                                           (
                                           color: Colors.white,
                                         ),
                                       ),
                                       contentPadding: const EdgeInsets.symmetric
                                         (
                                         horizontal:17,
                                         vertical: 10,
                                       ),
                                       fillColor: Colors.white38,
                                       filled: true,
                                     ),
                                   ),
                               ),
                                const SizedBox(height: 15,),

                                //button Login
                                Material
                                  (
                                  color: Colors.indigo,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell
                                    (
                                    onTap: ()
                                    {
                                      if(formKey.currentState!.validate())
                                      {
                                        loginUserNow();
                                      }
                                    },
                                    borderRadius:BorderRadius.circular(30),
                                    child: const Padding
                                      (
                                      padding: EdgeInsets.symmetric
                                        (
                                        vertical: 10,
                                        horizontal: 30,
                                      ),
                                      child: Text
                                        (
                                        "Login",

                                        style: TextStyle
                                          (
                                          color: Colors.white,
                                          fontSize: 16
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15,),
                              ],
                            ),
                          ),

                          //Don't have an acc button
                          Row
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            [
                              const Text("Dont have an account?", style: TextStyle
                                (
                                  color: Colors.black,
                                  fontSize: 17,
                              ),
                              ),
                              TextButton(onPressed:()
                              { //Redirect to action, Sign up
                                Get.to(SignUpScreen());
                                
                              },
                                child: const Text
                                  (
                                  "Sign up here!",
                                  style: TextStyle
                                    (
                                      color: Colors.white,
                                      fontSize: 17
                                  ),

                                ),
                              ),

                            ],
                          ),

                          const Text("or", style: TextStyle
                            (
                              color: Colors.black,
                              fontSize: 17
                          ),
                          ),

                          //admin login
                          Row
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            [
                              const Text("Admin login",
                                style: TextStyle
                                (
                                  color: Colors.black,
                                  fontSize: 12,
                              ),
                              ),

                              TextButton(onPressed:()
                              {
                                Get.to(AdminLoginScreen());
                              },
                                child: const Text
                                  (
                                  "Click here!",
                                  style: TextStyle
                                    (
                                      color: Colors.white,
                                      fontSize: 12
                                  ),

                                ),

                              ),

                            ],

                          ),
                          const SizedBox(height: 15, ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
              ),
            ),
          );
        },
      )
      ),
    );
  }
}

