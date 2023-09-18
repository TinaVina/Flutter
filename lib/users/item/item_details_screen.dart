import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/cart/cart_list_screen.dart';
import 'package:furniture_store_app/users/controllers/item_details_controller.dart';
import 'package:furniture_store_app/users/model/furniture.dart';
import 'package:furniture_store_app/users/userPreferences/current_user.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class itemDetailsScreen extends StatefulWidget {

  final Furniture? itemInfo;
  itemDetailsScreen({this.itemInfo, });

  @override
  State<itemDetailsScreen> createState() => _itemDetailsScreenState();
}

class _itemDetailsScreenState extends State<itemDetailsScreen> {

  final itemDetailsControllerInst=Get.put(itemDetailsController());
  final currentOnlineUser= Get.put(CurrentUser());

  addItemsToCart()async{
    try{
      var res= await http.post
        (
        Uri.parse(API.addItemsToCart),
        body:
        {
          "user_id": currentOnlineUser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),
          "quantity": itemDetailsControllerInst.quantity.toString(),
          "color":  widget.itemInfo!.colors![itemDetailsControllerInst.color],
          "size": widget.itemInfo!.sizes![itemDetailsControllerInst.size],
        },
      );
      if(res.statusCode==200) {
        var resBodyOfAddToCart = jsonDecode(res.body);
        if (resBodyOfAddToCart['success'] == true) {
          Fluttertoast.showToast(msg: "Item added to cart.");
        }
        else {
          Fluttertoast.showToast(msg: "Error occured.\nTry again!");
        }
      }
    }
    catch(e){
      print("Error"+ e.toString());
    }


  }

  validateFavoriteItems()async{
    try{
      var res= await http.post
        (
        Uri.parse(API.validateFavorites),
        body:
        {
          "user_id": currentOnlineUser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),

        },
      );
      if(res.statusCode==200) {
        var resBodyOfValFavorites= jsonDecode(res.body);
        if (resBodyOfValFavorites['favoriteFound'] == true) {
          //Fluttertoast.showToast(msg: "Item added to favorites.");

          itemDetailsControllerInst.setFavoriteItem(true);

        }
        else {


          itemDetailsControllerInst.setFavoriteItem(false);
        }
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  addFavoriteItems()async{
    try{
      var res= await http.post
        (
        Uri.parse(API.addFavorites),
        body:
        {
          "user_id": currentOnlineUser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),

        },
      );
      if(res.statusCode==200) {
        var resBodyOfFavorites= jsonDecode(res.body);
        if (resBodyOfFavorites['success'] == true) {
          Fluttertoast.showToast(msg: "Added to favorites.");
          validateFavoriteItems();
        }
        else {
          Fluttertoast.showToast(msg: "Error occured.\nTry again!");
        }
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  deleteFavoriteItems()async{
    try{
      var res= await http.post
        (
        Uri.parse(API.deleteFavorites),
        body:
        {
          "user_id": currentOnlineUser.user.user_id.toString(),
          "item_id": widget.itemInfo!.item_id.toString(),

        },
      );
      if(res.statusCode==200) {
        var resBodyOfFavorites= jsonDecode(res.body);
        if (resBodyOfFavorites['success'] == true) {
          Fluttertoast.showToast(msg: "Items removed from favorites.");
          validateFavoriteItems();
        }
        else {
          //Fluttertoast.showToast(msg: "Error occured.\nTry again!");
        }
      }
    }
    catch(e){
      print(e.toString());
    }
  }

  @override
  void initState() {
    //is the item already on favorites list?
    validateFavoriteItems();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade500,
      body: Stack(
        children: [
          FadeInImage(
            height: MediaQuery.of(context).size.height*0.5,
            width: MediaQuery.of(context).size.width  ,
            fit: BoxFit.cover,
            placeholder: const AssetImage("images/furntsy_home_1.png"),
            image: NetworkImage(
              widget.itemInfo!.image!,
            ),
            imageErrorBuilder: (context, error,stateTraceError){
              return Center(
                child: Icon(
                  Icons.broken_image_outlined,
                ),
              );
            },

          ),

          //display item info
          Align(
          alignment: Alignment.bottomCenter,
          child: itemInfoWidget(),
          ),

          //buttons-favorite
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white38,
              child: Row(
                children: [

                  //back button
                  IconButton(
                    onPressed: (){
                      Get.back();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                          color: Colors.indigo,
                      size: 40,
                    ),
                  ),

                  const Spacer(),
                  //favorites button
                  Obx(
                      ()=>IconButton(
                        onPressed: ()
                        {
                          if(itemDetailsControllerInst.isFavorite){
                            deleteFavoriteItems();
                          }
                          else{
                            addFavoriteItems();
                          }
                        },
                        icon: Icon(
                            itemDetailsControllerInst.isFavorite ?  CupertinoIcons.heart_solid: CupertinoIcons.heart,
                          color: Colors.red,
                          size: 38,
                        ),

                      ),

                  ),

                  IconButton(
                    onPressed: (){
                     // Get.to(CartListScreen());
                    addItemsToCart();
                    },
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: Colors.indigo,
                      size: 38,
                    ),
                  ),

                ],
              ),
            ),
          ),


        ],
      ),
    );
  }

  itemInfoWidget()
  {
    return Container(

      height: MediaQuery.of(context).size.height *0.6,
      width: MediaQuery.of(context).size.width ,
     decoration: BoxDecoration(
       gradient: const LinearGradient(
         colors: [
           Colors.cyan,
           Colors.indigo,

         ],
       ),
       borderRadius: const BorderRadius.only(
         topLeft:Radius.circular(40),
         topRight: Radius.circular(40),

       ),
       boxShadow: [
         BoxShadow(
           offset: Offset(0,-6),
           blurRadius: 8,
           color: Colors.blue.shade200,
         ),
       ],
     ),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18,),
            Center(
              child: Container(
                height: 8,
                  width: 140,
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                
              ),
            ),
            const SizedBox(height: 30,),

            //name
            Text(
              widget.itemInfo!.name!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10,),

            //rating, tags, price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: widget.itemInfo!.rating!,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemBuilder: (context, c)=> const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (updateRating){},
                          ignoreGestures: true,
                          unratedColor: Colors.grey,
                          itemSize: 35,
                        ),

                        const SizedBox(width: 8,),
                        Text(
                          "{"+widget.itemInfo!.rating.toString()+"}",
                          style: const TextStyle(
                            fontSize: 21,
                            color: Colors.black,
                          ),
                        ),


                      ],
                    ),

                    const SizedBox(height: 10,),

                    Text(
                      "\#"+widget.itemInfo!.tags!.toString().replaceAll("[", "").replaceAll("]", ""),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        color: Colors.indigo.shade900,
                      ),

                    ),

                    const SizedBox(height: 13,),

                    Text(
                      "\$"+widget.itemInfo!.price!.toString(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade900,
                      ),

                    ),

                  ],
                ),
                ),
              ],
            ),

            const SizedBox(height: 15,),

            Text(
              "Quantity",
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15,),
            Obx(

                ()=>Column(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  IconButton(
                    onPressed: ()
                    {
                      itemDetailsControllerInst.setQuantityItem(itemDetailsControllerInst.quantity + 1);
                    },
                    icon: Icon(Icons.add_circle_outline, color: Colors.indigo,),
                  ),

                    Text(
                      itemDetailsControllerInst.quantity.toString(),
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: ()
                      {
                        if(itemDetailsControllerInst.quantity -1 >= 1 ){
                          itemDetailsControllerInst.setQuantityItem(itemDetailsControllerInst.quantity - 1);

                        }
                        else{
                          Fluttertoast.showToast(msg: "Quantity must be equal or greater than 1");
                        }

                      },
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.indigo,),
                    ),


                  ],
                ),
            ),

            const SizedBox(height: 15,),

            Text(
              "Size",
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 10,),
            
            Wrap(
              runSpacing: 8,
              spacing: 8,
              children:
                List.generate(widget.itemInfo!.sizes!.length, (index)
                {
                  return Obx(()=>GestureDetector(
                    onTap: (){
                      itemDetailsControllerInst.setSizeItem(index);
                    },
                    child: Container(
                      height: 50,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color:  itemDetailsControllerInst.size==index ?  Colors.green.shade700 : Colors.blue.shade900,
                        ),
                        borderRadius: BorderRadius.circular(30),

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.itemInfo!.sizes![index].replaceAll("[", "").replaceAll("]", ""),
                          style: TextStyle(
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ),
                  ),
                  );
                }),

            ),

            const SizedBox(height: 10,),

            Text(
              "Colors",
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10,),

            Wrap(
              runSpacing: 8,
              spacing: 8,
              children:
              List.generate(widget.itemInfo!.colors!.length, (index)
              {
                return Obx(()=>GestureDetector(
                  onTap: (){
                    itemDetailsControllerInst.setColorsItem(index);
                  },
                  child: Container(
                    height: 50,
                    width: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color:  itemDetailsControllerInst.color==index ?  Colors.green.shade700 : Colors.blue.shade900,
                      ),
                      borderRadius: BorderRadius.circular(30),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.itemInfo!.colors![index].replaceAll("[", "").replaceAll("]", ""),
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  ),
                ),
                );
              }),

            ),

            const SizedBox(height: 15,),

            Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8,),
            Text(
              widget.itemInfo!.description!,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 20,

              ),

            ),

            const SizedBox(height: 15,),

            Material(
              elevation: 4,
              color: Colors.indigo.shade800,
              borderRadius: BorderRadius.circular(20),

              child: InkWell(

                onTap: (){
                  addItemsToCart();
                },

                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Container(

                    height: 50,
                    width: 400,
                    alignment: Alignment.center,
                    child: const Text(
                      "Add to cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15,),


          ],
        ),
      ),

    );
  }
}
