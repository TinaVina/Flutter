import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/cart/cart_list_screen.dart';
import 'package:furniture_store_app/users/item/item_details_screen.dart';
import 'package:furniture_store_app/users/item/search_items.dart';
import 'package:furniture_store_app/users/model/furniture.dart';
import 'package:http/http.dart'as http;
import 'package:get/get.dart';

class HomeFragmentScreen extends StatelessWidget
{
  TextEditingController searchcontroller=TextEditingController();

  Future<List<Furniture>>getTrendingItems()async
  {
    List<Furniture> listTrendingItems=[];

    try
    {
      var res=await http.post(
        Uri.parse(API.getTrending)
      );
      if(res.statusCode==200)
      {
        var responseBody= jsonDecode(res.body);//success

        if(responseBody["success"]==true){
          (responseBody["furnitureItemsData"]as List).forEach((eachRow) {
            listTrendingItems.add(Furniture.fromJson(eachRow));
          });
        }

      }
      else{
        Fluttertoast.showToast(msg: "Error, status code not 200.");
      }
      
    }
    catch(e)
    {
      print("Error"+e.toString());
    }

    return listTrendingItems;
  }

  Future<List<Furniture>>getAllFurnitureItems()async
  {
    List<Furniture> listAllItems=[];

    try
    {
      var res=await http.post(
          Uri.parse(API.getAllFurniture)
      );
      if(res.statusCode==200)
      {
        var responseBodyofAll= jsonDecode(res.body);//success

        if(responseBodyofAll["success"]==true){
          (responseBodyofAll["furnitureItemsData"]as List).forEach((eachRow) {
            listAllItems.add(Furniture.fromJson(eachRow));
          });
        }
      }
      else{
        Fluttertoast.showToast(msg: "Error, status code not 200.");
      }
    }
    catch(e)
    {
      print("Error"+e.toString());
    }

    return listAllItems;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 15,),
          showSearchBar(),
          const SizedBox(height: 20,),
          //trending items
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Trending",
              style: TextStyle(
              color: Colors.indigo,
                fontSize: 20,
                fontWeight: FontWeight.bold,

            ),
            ),
          ),

          trendingFurnitureWidget(context),

          const SizedBox(height: 20,),
          const Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "New Arrivals",
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 20,
                fontWeight: FontWeight.bold,

              ),
            ),
          ),

          allNewItemsWidget(context),



        ],
      ),
    );
  }

  Widget showSearchBar(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        style: const TextStyle(
          color: Colors.white),
          controller: searchcontroller,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            onPressed: ()
            {
              Get.to(searchItem(searchKeywords: searchcontroller.text));
            },
            icon: const Icon(
              Icons.search_sharp,
              color: Colors.indigo,
              size: 30,
            ),
          ),
          hintText: "Search",
          hintStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20),
            suffixIcon: IconButton(
              onPressed: (){
                Get.to(()=>CartListScreen());
              },
              icon: const Icon(
                Icons.shopping_cart,
                color: Colors.indigo,
                size: 30,
              ),
            ),
          border:const  OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.blueGrey,

            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(
              width: 2,
              color: Colors.indigo,
              

            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(
              width: 2,
              color: Colors.white,


            ),
          ),
          ),
      ),
    );
  }

  Widget trendingFurnitureWidget(context)
  {

    return FutureBuilder(
      future: getTrendingItems(),
      builder: (context, AsyncSnapshot<List<Furniture>>dataSnapshot)
      {
        if(dataSnapshot.connectionState== ConnectionState.waiting)
        {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if(dataSnapshot.data==null)
        {
          return Center(
              child: Text(
          "No trending items found",
          ),
          );
        }
        if(dataSnapshot.data!.length>0)
        {
          return SizedBox(
            height: 270,
            child: ListView.builder(
              itemCount: dataSnapshot.data!.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index)
              {
                Furniture eachFurnitureItem= dataSnapshot.data![index];
                return GestureDetector(
                  onTap: ()
                  {
                    Get.to(itemDetailsScreen(itemInfo: eachFurnitureItem));
                  },
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.fromLTRB(
                      index==0 ? 16: 8,
                      10,
                      index==dataSnapshot.data!.length-1 ? 16: 8,
                      10,


                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.indigoAccent,
                      boxShadow: [BoxShadow(
                        offset: Offset(0,3),
                        blurRadius: 6,
                        color: Colors.indigo,
                      ),]
                    ),
                    child: Column(
                      children: [
                        
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            topLeft: Radius.circular(20),
                          ),
                          child: FadeInImage(
                            height: 150,
                              width: 200,
                              fit: BoxFit.cover,
                            placeholder: const AssetImage("images/furntsy_home_1.png"),
                            image: NetworkImage(
                              eachFurnitureItem.image!,
                            ),
                            imageErrorBuilder: (context, error,stateTraceError){
                              return Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                ),
                              );
                            },

                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eachFurnitureItem.name!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    eachFurnitureItem.price.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10,),

                              Row(
                                children: [
                                  //rating stars and number
                                  RatingBar.builder(
                                    initialRating: eachFurnitureItem.rating!,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemBuilder: (context, c)=>Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (updateRating){},
                                    ignoreGestures: true,
                                    unratedColor: Colors.grey,
                                    itemSize: 20,
                              ),
                                  const SizedBox(width: 8,),
                                  Text(
                                    "{"+eachFurnitureItem.rating.toString()+"}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        else{
          return const Center(
            child: Text(
              "Empty, No data",
            ),
          );
        }
      },
    );

  }

  allNewItemsWidget(context){

    return FutureBuilder(
      future: getAllFurnitureItems(),
        builder: (context, AsyncSnapshot<List<Furniture>>dataSnapshot){
          if(dataSnapshot.connectionState== ConnectionState.waiting)
          {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if(dataSnapshot.data==null)
          {
            return Center(
              child: Text(
                "No new items found",
              ),
            );
          }
          if(dataSnapshot.data!.length>0)
          {
            return ListView.builder(
              itemCount: dataSnapshot.data!.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index)
              {
                Furniture eachFurnitureItem= dataSnapshot.data![index];
               return GestureDetector(
                 onTap: ()
                 {
                   Get.to(itemDetailsScreen(itemInfo: eachFurnitureItem));
                 },
                 child: Container(
                   margin: EdgeInsets.fromLTRB(
                     16,
                     index==0 ? 16: 8,
                     16,
                     index==dataSnapshot.data!.length -1 ? 16 : 8,

                   ),
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(20),
                       color: Colors.indigoAccent,
                       boxShadow: [BoxShadow(
                         offset: Offset(0,0),
                         blurRadius: 6,
                         color: Colors.indigo,
                       ),]
                   ),

                   child: Row(
                     children: [
                       //name, tags, price
                       Expanded(
                         child: Padding(
                           padding: EdgeInsets.only(left: 16),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 children: [
                                   Expanded(child: Text(
                                     eachFurnitureItem.name!,
                                     maxLines: 2,
                                     overflow: TextOverflow.ellipsis,
                                     style: TextStyle(
                                       fontSize: 18,
                                       fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                     ),
                                   ),
                                   ),

                                   //price
                                   Padding(
                                     padding: const EdgeInsets.only(left: 10, right: 8),
                                     child: Text(
                                       "\$"+eachFurnitureItem.price.toString(),
                                       maxLines: 2,
                                       overflow: TextOverflow.ellipsis,
                                       style: TextStyle(
                                         fontSize: 18,
                                         fontWeight: FontWeight.bold,
                                         color: Colors.white,
                                       ),
                                     ),
                                   ),

                                 ],
                               ),

                               const SizedBox(height: 16,),

                               Text(
                                 "Tags:\n "+"\#"+eachFurnitureItem.tags.toString().replaceAll("[", "").replaceAll("]", ""),
                                 maxLines: 2,
                                 overflow: TextOverflow.ellipsis,
                                 style: TextStyle(
                                   fontSize: 18,
                                   color: Colors.indigo.shade900,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),

                       //item images
                       ClipRRect(
                         borderRadius: BorderRadius.only(
                           bottomRight: Radius.circular(20),
                           topRight: Radius.circular(20),
                         ),
                         child: FadeInImage(
                           height: 130,
                           width: 130,
                           fit: BoxFit.cover,
                           placeholder: const AssetImage("images/furntsy_home_1.png"),
                           image: NetworkImage(
                             eachFurnitureItem.image!,
                           ),
                           imageErrorBuilder: (context, error,stateTraceError){
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
               );
              },
            );
          }

          else{
            return const Center(
              child: Text(
                "Empty, no data",
              ),
            );
          }
        }
    );
  }


}
