import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminUploadItemsScreen extends StatefulWidget
{
  @override
  State<AdminUploadItemsScreen> createState() => _AdminUploadItemsScreenState();
}

class _AdminUploadItemsScreenState extends State<AdminUploadItemsScreen>
{
  final ImagePicker _picker=ImagePicker();
  XFile? pickedImgXFile;
  var formKey=GlobalKey<FormState>();
  var nameController = TextEditingController();
  var ratingController = TextEditingController();
  var tagsController = TextEditingController();
  var priceController = TextEditingController();
  var sizeController = TextEditingController();
  var colorsController = TextEditingController();
  var descriptionController = TextEditingController();
  var ImageLink="";

  captureImgWithCamera()async{
    //open up camera to capture
    pickedImgXFile= await _picker.pickImage(source: ImageSource.camera);

    Get.back();
    setState(()=> pickedImgXFile);
  }

  chooseImgFromGallery()async{
    //open up gallery
    pickedImgXFile= await _picker.pickImage(source: ImageSource.gallery);

    Get.back();
    setState(()=> pickedImgXFile);
  }

  showDialogBoxForPickingImgAndCapture(){
    return showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
          title: const Text(
            "Item image",
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: (){
                captureImgWithCamera();
              },
              child: const Text(
                "Capture with phone camera",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,

                ),
              ),
            ),
            const SizedBox(height: 10,),
            SimpleDialogOption(
              onPressed: (){
                chooseImgFromGallery();
              },
              child: const Text(
                "Select image from gallery",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,


                ),
              ),
            ),
            const SizedBox(height: 10,),
            SimpleDialogOption(
              onPressed: (){
                Get.back();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,

                ),
              ),
            ),
          ],
        );
      }
    );
  }

  Widget defaultScreen(){
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Colors.indigo,
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: true,

        title: const Text(
            "Welcome Admin"
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo,
              Colors.cyan,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.black,
                size: 180,
              ),

              const SizedBox(height: 20,),

              Material
                (
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
                child: InkWell
                  (
                  onTap: ()
                  {
                    showDialogBoxForPickingImgAndCapture();
                  },
                  borderRadius:BorderRadius.circular(20),
                  child: const Padding
                    (
                    padding: EdgeInsets.symmetric
                      (
                      vertical: 15,
                      horizontal: 35,
                    ),
                    child: Text
                      (
                      "Add new item",

                      style: TextStyle
                        (
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  uploadItemImage()async{
    var requestImgurApi= http.MultipartRequest(//sending request to imgur api
      "POST",
      Uri.parse("https://api.imgur.com/3/image")//here is where we send our request
    );
    
    String imageName=DateTime.now().microsecondsSinceEpoch.toString(); // a unique name for the image
    requestImgurApi.fields['title'] = imageName;
    requestImgurApi.headers['Authorization']= "Client-ID " + "32acbc0ebd2d7ed";

    var imageFile= await http.MultipartFile.fromPath(
      'image',
      pickedImgXFile!.path,
      filename: imageName,
    );

    requestImgurApi.files.add(imageFile);
    var responseFromImgurApi= await requestImgurApi.send();
    var responseDataFromImgurApi= await responseFromImgurApi.stream.toBytes();
    var resultImgurApi =String.fromCharCodes(responseDataFromImgurApi);

    print("Result: ");//the result is shown in json format, but we only need the link information
    print(resultImgurApi);
    
    Map<String, dynamic>jsonResponse=jsonDecode(resultImgurApi);//coverted to string, more readable data
    ImageLink= (jsonResponse["data"]["link"]).toString();
    String deleteHash= (jsonResponse["data"]["deletehash"]).toString();

    //besides the result, it also writes the link in correct form and the delete hash
    print("Image link: ");
    print(ImageLink);

    print("Delete hash: ");
    print(deleteHash);

    saveItemInfoToDB();


  }

  saveItemInfoToDB()async
  {
    List<String> tagslist= tagsController.text.split(',');
    List<String> sizeslist= sizeController.text.split(',');//or space
    List<String> colorslist= colorsController.text.split(',');
    
    try{
      var respponse =await http.post(
        Uri.parse(API.uploadNewItem),
        body: {

          'item_id': '1',
          'name': nameController.text.trim().toString(),
          'rating': ratingController.text.trim().toString(),
          'tags': tagslist.toString(),
          'price': priceController.text.trim().toString(),
          'sizes': sizeslist.toString(),
          'colors': colorslist.toString(),
          'description': descriptionController.text.trim().toString(),
          'image': ImageLink.toString(),

      },
      );

      if(respponse.statusCode==200)
      {
        var resBodyOfUploadItem= jsonDecode(respponse.body);

        if(resBodyOfUploadItem ['success']== true)
        {
          Fluttertoast.showToast(msg:"New item uploaded successfully!");
          setState(() {
            pickedImgXFile=null;
            nameController.clear();
            tagsController.clear();
            priceController.clear();
            ratingController.clear();
            sizeController.clear();
            colorsController.clear();
            descriptionController.clear();

          });
          Get.to(AdminUploadItemsScreen());
        }
        else
        {
          Fluttertoast.showToast(msg:"Item not uploaded. Try again!");
        }

      }
      else{
        Fluttertoast.showToast(msg:"Status code not 200");
      }
    }
    catch(e){
      print(e.toString());
    }
    }

  Widget uploadItemFormScreen()
  {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Colors.indigo,
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          "Upload new item",
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: ()
          {
            //if the admin  want to cancel or upload
          setState(() {
            pickedImgXFile=null;
            nameController.clear();
            tagsController.clear();
            priceController.clear();
            ratingController.clear();
            sizeController.clear();
            colorsController.clear();
            descriptionController.clear();

          });
            Get.to(AdminUploadItemsScreen());
          },
          icon: const Icon(
            Icons.clear,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: ()
            {
              Fluttertoast.showToast(msg:"Uploading starts!");
              uploadItemImage();
            },
            icon: const Icon(
              Icons.done,
              size: 30,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(
                  File(pickedImgXFile!.path),
                ),
                fit: BoxFit.cover,

              ),
            ),
          ),

          //upload item screen
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
                          TextFormField //input from User for item name
                            (
                            controller: nameController,
                            validator: (val)=> val == "" ? "Please write item name!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.title,
                                color: Colors.white,

                              ),
                              hintText: "Item name",
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

                          TextFormField //item rating
                            (
                            controller: ratingController,
                            validator: (val)=> val == "" ? "Please give item ratings!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.rate_review_outlined,
                                color: Colors.white,

                              ),
                              hintText: "Item rating",
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

                          TextFormField //item tags
                            (
                            controller: tagsController,
                            validator: (val)=> val == "" ? "Please give item tags!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.tag,
                                color: Colors.white,

                              ),
                              hintText: "Item tags",
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

                          TextFormField //item price
                            (
                            controller: priceController,
                            validator: (val)=> val == "" ? "Please write item price!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.attach_money_outlined,
                                color: Colors.white,

                              ),
                              hintText: "Item price",
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

                          TextFormField //item size
                            (
                            controller: sizeController,
                            validator: (val)=> val == "" ? "Please give item sizes!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.chair,
                                color: Colors.white,

                              ),
                              hintText: "Item size",
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

                          TextFormField //item colors
                            (
                            controller: colorsController,
                            validator: (val)=> val == "" ? "Please give item colors!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.color_lens_outlined,
                                color: Colors.white,

                              ),
                              hintText: "Item color",
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

                          TextFormField //item description
                            (
                            controller: descriptionController,
                            validator: (val)=> val == "" ? "Please write item description!" : null , //checks whether the user has inputed an email, if not writes out validation message
                            decoration: InputDecoration
                              (
                              prefixIcon:  const Icon
                                (
                                Icons.description_outlined,
                                color: Colors.white,

                              ),
                              hintText: "Item description",
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

                          //button Upload
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
                                  Fluttertoast.showToast(msg:"Uploading starts!");
                                  uploadItemImage();
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
                                  "Upload",

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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pickedImgXFile==null ? defaultScreen() : uploadItemFormScreen();//if the admin does not choose an img, get back to default screen, else send him to uploadItemFormScreen
  }
}
