import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/controllers/cart_list_controller.dart';
import 'package:furniture_store_app/users/item/item_details_screen.dart';
import 'package:furniture_store_app/users/model/furniture.dart';
import 'package:furniture_store_app/users/order/order_screen.dart';
import 'package:furniture_store_app/users/userPreferences/current_user.dart';
import 'package:get/get.dart';
import 'package:furniture_store_app/users/model/cart.dart';
import 'package:http/http.dart'as http;

class CartListScreen extends StatefulWidget
{
  @override
  State<CartListScreen> createState() => _CartListScreenState();
}

class _CartListScreenState extends State<CartListScreen> {

  final currentOnlineUser=Get.put(CurrentUser());
  final cartListController= Get.put(CartListController());

  getCartList()async
  {//current user
    List<cart> cartListOfCurrentUser=[];
    try{
      var res= await http.post(Uri.parse(API.getCartList),
        body: {
        "currentOnlineUserID": currentOnlineUser.user.user_id.toString(),
        }

      );

      if(res.statusCode==200){
        var resBodyOfCurrentUserCartItems= jsonDecode(res.body);
        if(resBodyOfCurrentUserCartItems['success']==true)
        {
          (resBodyOfCurrentUserCartItems['currentUserCartData']as List).forEach((eachCurrentUserCartItem)
          {
            cartListOfCurrentUser.add(cart.fromJson(eachCurrentUserCartItem));
          });
        }
        else
        {
          //Fluttertoast.showToast(msg: "Error occured.");
        }
        cartListController.setList(cartListOfCurrentUser);
        }
      else
      {
        Fluttertoast.showToast(msg: "Status code not 200!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg:e.toString());
    }
    calculateTotalAmount();

  }

  calculateTotalAmount(){ //all items in cart
    cartListController.setTotal(0);

    if(cartListController.selectedItemList.length>0)
    {
      cartListController.cartList.forEach((itemInCart) {
        if(cartListController.selectedItemList.contains(itemInCart.cart_id)){
          double eachtotalAmount= (itemInCart.price!) * (double.parse(itemInCart.quantity.toString()));


          cartListController.setTotal(cartListController.total + eachtotalAmount); //0+ amount
        }
        
      });
    }

  }


  deleteSelectedItems(int cartID)async{
    try{
      var res= await http.post(
        Uri.parse(API.deleteSelectedItemsFromCart),
        body: {
          "cart_id": cartID.toString(),
        },

      );
      if(res.statusCode==200){
        var resposneBodyDelete= jsonDecode(res.body);
        if(resposneBodyDelete["success"]){
          getCartList();
        }
      }
      else{
        Fluttertoast.showToast(msg: "Error: Status code not 200");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  updateQuantityInUserCart(int cartID, int newQuantity) async
  {
    try
    {
      var res = await http.post(
          Uri.parse(API.updateSelectedItemsFromCart),
          body:
          {
            "cart_id": cartID.toString(),
            "quantity": newQuantity.toString(),
          }
      );

      if(res.statusCode == 200)
      {
        var responseBodyOfUpdateQuantity = jsonDecode(res.body);

        if(responseBodyOfUpdateQuantity["success"] == true)
        {
          getCartList();
        }
      }
      else
      {
        Fluttertoast.showToast(msg: "Error, Status Code is not 200");
      }
    }
    catch(errorMessage)
    {
      print("Error: " + errorMessage.toString());

      Fluttertoast.showToast(msg: "Error: " + errorMessage.toString());
    }
  }

 List<Map<String, dynamic>>getSelectedItemsInfo(){
   List<Map<String, dynamic>> selectedItemsInfo =[];

   if(cartListController.selectedItemList.length>0) //if the user has selected any items
   {
     cartListController.cartList.forEach((cartItem)
     {
       if (cartListController.selectedItemList.contains(cartItem.cart_id))
       {
         Map<String, dynamic> itemInformations =
         {
           "item_id": cartItem.item_id,
           "name": cartItem.name,
           "color": cartItem.color,
           "size": cartItem.size,
           "image": cartItem.image,
           "quantity": cartItem.quantity,
           "totalAmount": cartItem.price! * cartItem.quantity!,

         };
         selectedItemsInfo.add(itemInformations);
       }
     });
   }
   return selectedItemsInfo;
 }

  @override
  void initState(){
    super.initState();
    getCartList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.cyan.shade700,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
            "My Cart"
        ),
        actions: [
          Obx(
                ()=>//select all
            IconButton(onPressed:()
            {
              cartListController.setIsSelectedAllItems();
              cartListController.clearAllSelectedItems();
              if(cartListController.isSelectedAll){
                cartListController.cartList.forEach((item) {
                  cartListController.addSelectedItem(item.cart_id!);
                });
              }
              calculateTotalAmount();
            },

              icon: Icon(
                  cartListController.isSelectedAll ? Icons.check_box : Icons.check_box_outline_blank,
              color: cartListController.isSelectedAll ? Colors.white : Colors.grey,
              ),
            ),
          ),
          
          GetBuilder(
            init: CartListController(),
            builder: (c){
              if(cartListController.selectedItemList.length>0){
                return IconButton(
                  onPressed: ()async{ //cause we wait for the response, what will the user click on
                    var responseFromDeletedDialof=await Get.dialog(
                      AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text(
                          "Delete"
                        ),
                        content: const Text(
                          "Are you sure you want to delete selected items?"
                        ),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Get.back();
                            },
                            child: const Text(
                              "No",
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: (){
                              Get.back(result: "yesDelete");
                            },
                            child: const Text(
                              "Yes",

                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    if(responseFromDeletedDialof=="yesDelete"){
                      cartListController.selectedItemList.forEach((selectedItemID) {
                        deleteSelectedItems(selectedItemID);

                      });
                    }
                    calculateTotalAmount();
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 25,
                  ),
                );
                
              }
              else{
                return Container();
              }
            },
          ),
          
        ],
      ),
      body: Obx(
              () =>
          cartListController.cartList.length > 0 ?
          ListView.builder(
            itemCount: cartListController.cartList.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              cart cartModel = cartListController.cartList[index];
              Furniture furnitureModel = Furniture(
                item_id: cartModel.item_id,
                colors: cartModel.colors,
                sizes: cartModel.sizes,
                image: cartModel.image,
                price: cartModel.price,
                rating: cartModel.rating,
                description: cartModel.description,
                tags: cartModel.tags,
                name: cartModel.name,

              );

              return SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Row(
                  children: [
                    GetBuilder(
                      init: CartListController(),
                      builder: (c) {
                        return IconButton(
                          onPressed: () {

                            if(cartListController.selectedItemList.contains(cartModel.cart_id)){
                              //
                              cartListController.deleteSelectedItem(cartModel.cart_id!);

                            }
                            else {
                              cartListController.addSelectedItem(
                                  cartModel.cart_id!);
                            }
                            calculateTotalAmount();
                          },
                          icon: Icon(
                            cartListController.selectedItemList.contains(
                                cartModel.cart_id)
                                ? Icons.check_box : Icons
                                .check_box_outline_blank,
                            color: cartListController.isSelectedAll ? Colors
                                .white : Colors.black,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.to(itemDetailsScreen(itemInfo: furnitureModel));
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                            0,
                            index == 0 ? 16 : 8,
                            16,
                            index == cartListController.cartList.length - 1
                                ? 16
                                : 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.indigo.shade700,
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 8,
                                color: Colors.cyan,

                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        furnitureModel.name.toString(),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),

                                      ),

                                      const SizedBox(height: 20,),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Color: ˘${cartModel.color!
                                                  .replaceAll("[", "")
                                                  .replaceAll("]", " ")}" +
                                                  "\n" +
                                                  "Size: ˘${cartModel.size!
                                                      .replaceAll('[', '')
                                                      .replaceAll(']', '')}",
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),


                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 12,
                                                right: 3.0
                                            ),
                                            child: Text(
                                              "\$" + furnitureModel.price
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 20,),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if(cartModel.quantity!-1>=1){
                                                if(cartModel.quantity! - 1 >= 1)
                                                {
                                                  updateQuantityInUserCart(
                                                    cartModel.cart_id!,
                                                    cartModel.quantity! - 1,//cause this is the decrement
                                                  );
                                                }

                                              }
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),

                                          const SizedBox(width: 10,),

                                          Text(
                                            cartModel.quantity.toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),

                                          const SizedBox(width: 10,),

                                          IconButton(
                                            onPressed: () {
                                              updateQuantityInUserCart(
                                                cartModel.cart_id!,
                                                cartModel.quantity! + 1,
                                              );
                                            },
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),

                                        ],
                                      ),
                                      //increment


                                    ],
                                  ),
                                ),
                              ),

                              //item images
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(22),
                                  bottomRight: Radius.circular(22),
                                ),
                                child: FadeInImage(
                                  height: 190,
                                  width: 150,
                                  fit: BoxFit.cover,
                                  placeholder: const AssetImage(
                                      "images/place_holder.png"),
                                  image: NetworkImage(
                                    cartModel.image!,
                                  ),
                                  imageErrorBuilder: (context, error,
                                      stateTraceError) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                      ),
                                    );
                                  },

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
            },
          )
              : const Center(
            child: Text(
                "Cart is empty"
            ),
          )
      ),

      bottomNavigationBar: GetBuilder(
        init: CartListController(),
        builder: (c) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.indigo,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, -3),
                  color: Colors.white24,
                  blurRadius: 6,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children:
              [
                //total amount
                const Text(
                  "Total Amount:",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Obx(() =>
                    Text(
                      "\$ " + cartListController.total.toStringAsFixed(2),
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ),

                const Spacer(),

                //order now btn
                Material(
                  color: cartListController.selectedItemList.length > 0
                      ? Colors.cyan
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    onTap: ()
                    { //first check if item is selected
                      cartListController.selectedItemList.length > 0 ? Get.to(OrderScreen(selectedCartItem :getSelectedItemsInfo() , totalAmount : cartListController.total, cartIDList: cartListController.selectedItemList )) : null;

                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        "Order Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),


    );
  }
}
