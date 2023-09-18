import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/authentication/login_screen.dart';
import 'package:furniture_store_app/users/model/user.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class SignUpScreen extends StatefulWidget
{
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
{
  var formKey=GlobalKey<FormState>();
  var nameController= TextEditingController();
  var emailController= TextEditingController();
  var passwordController= TextEditingController();
  var isObsecure=true.obs;

  validateUserEmail()async //cause we wait for the response of the server
  {
    try
    {
      var res= await http.post
        ( //with the help of our API we connect to our Server
        Uri.parse(API.validateEmail),
        body:
        { //we have to pass it with the same name as in DB
          'user_email':emailController.text.trim(),
        },
      );
      if(res.statusCode == 200)//HTTP 200 OK status-request has succeded
      {
        var resBodyOfValidateEmail= jsonDecode(res.body);

        if(resBodyOfValidateEmail['emailFound'] == true)//email already in use
        {
          Fluttertoast.showToast(msg: "Email is already in use. Try again.");
        }
        else
        {
          //register and save to DB
          registerAndSaveUserRecord();
        }

      }
      else{
        Fluttertoast.showToast(msg:"Status code not 200");
      }
    }
    catch(e)
    {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  registerAndSaveUserRecord() async
  {
    User userModel= User
      (
      1,
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    try
    {
     var res= await http.post
        (
        Uri.parse(API.signUp),
        body: userModel.toJson(),
      );

     if(res.statusCode==200)
     {
       var resBodyOfSignUp=jsonDecode(res.body);
       if(resBodyOfSignUp['success']== true)
       {
         Fluttertoast.showToast(msg: "You have successfully signed up!");

         //after signing make sure the placeholders are empty
         setState(() {
           nameController.clear();
           emailController.clear();
           passwordController.clear();
         });
       }
       else
       {
         Fluttertoast.showToast(msg: "Error occured, try again!");
       }
     }
     
    }
    catch(e)
    {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context)

  {
    return Scaffold(
      backgroundColor: Colors.white12,
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
              [ //sign up screen header
                SizedBox
                  (
                  width: MediaQuery.of(context).size.width, // adjust to the size of the screen
                  height: 300,
                  child: Image.asset
                    (
                    "images/f2.jpg",
                  ),
                ),

                //sign up form
                Padding(
                  padding: const EdgeInsets.fromLTRB(30,20,30,5),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container //border around the email and password input
                      (
                      decoration:  const BoxDecoration
                        (
                        color: Colors.blueGrey,
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

                                TextFormField //input from User for name
                                  (
                                  controller: nameController,
                                  validator: (val)=> val == "" ? "Please write your name" : null , //checks whether the user has inputed an email, if not writes out validation message
                                  decoration: InputDecoration
                                    (
                                    prefixIcon:  const Icon
                                      (
                                      Icons.person,
                                      color: Colors.white,

                                    ),
                                    hintText: "name",
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
                                    fillColor: Colors.blueGrey,
                                    filled: true,
                                  ),
                                ),

                                const SizedBox(height: 15,),

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
                                    fillColor: Colors.blueGrey,
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
                                      fillColor: Colors.blueGrey,
                                      filled: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15,),

                                //button Sign up
                                Material
                                  (
                                  color: Colors.indigo,
                                  borderRadius: BorderRadius.circular(30),
                                  child: InkWell
                                    (
                                    onTap: ()
                                    {
                                      if(formKey.currentState!.validate()) //if the user has provided the username, email..
                                      {
                                        //validate email
                                        validateUserEmail();
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
                                        "Sign up",

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

                          //Already have an acc button
                          Row
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                            [
                              const Text("Already have an account?", style: TextStyle
                                (
                                color: Colors.black,
                                fontSize: 17,
                              ),
                              ),
                              TextButton(onPressed:()
                              {
                                Get.to(LoginScreen());
                              },
                                child: const Text
                                  (
                                  "Login here!",
                                  style: TextStyle
                                    (
                                      color: Colors.white,
                                      fontSize: 17
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

