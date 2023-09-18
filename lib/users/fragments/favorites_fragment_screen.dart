import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/item/item_details_screen.dart';
import 'package:furniture_store_app/users/model/furniture.dart';
import 'package:furniture_store_app/users/userPreferences/current_user.dart';
import 'package:http/http.dart' as http;
import '../model/favorite.dart';
import 'package:get/get.dart';

class FavoritesFragmentScreen extends StatelessWidget
{
    final currentOnlineUser=Get.put(CurrentUser());

  Future<List<Favorite>> getFavoritesList()async

  {//current user
    List<Favorite> faveListOfCurrentUser=[];

    try{
      var res= await http.post(Uri.parse(API.readFavorites),
          body: {
            "user_id": currentOnlineUser.user.user_id.toString(),
          }

      );

      if(res.statusCode==200){
        var resBodyOfFavItems= jsonDecode(res.body);
        if(resBodyOfFavItems['success']==true)
        {
          (resBodyOfFavItems['currentUserFavoriteData']as List).forEach((eachFaveItem)
          {
            faveListOfCurrentUser.add(Favorite.fromJson(eachFaveItem));
          });
        }

      }
      else
      {
        Fluttertoast.showToast(msg: "Status code not 200!");
      }
    }
    catch(e){
      Fluttertoast.showToast(msg:e.toString());
    }

    return faveListOfCurrentUser;

  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
              padding:EdgeInsets.all(20),
            child: Text(
              "Favorites",
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20,),

          //Favorits info
          FaveListWidget(context),
        ],
      ),
    );
  }

  FaveListWidget(context){

      return FutureBuilder(
          future: getFavoritesList(),
          builder: (context, AsyncSnapshot<List<Favorite>>dataSnapshot){
            if(dataSnapshot.connectionState== ConnectionState.waiting)
            {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if(dataSnapshot.data==null)
            {
              return const Center(
                child: Text(
                  "No favorites found",
                  style: TextStyle(
                    color: Colors.cyan,
                  ),
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
                  Favorite eachFaveItem= dataSnapshot.data![index];

                  Furniture furnitureItem=Furniture(
                    item_id: eachFaveItem.item_id,
                    colors: eachFaveItem.colors,
                    tags: eachFaveItem.tags,
                    description: eachFaveItem.description,
                    sizes: eachFaveItem.sizes,
                    rating: eachFaveItem.rating,
                    price: eachFaveItem.price,
                    name: eachFaveItem.name,
                    image: eachFaveItem.image,

                  );

                  return GestureDetector(
                    onTap: ()
                    {
                      Get.to(itemDetailsScreen(itemInfo: furnitureItem));
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
                                        eachFaveItem.name!,
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
                                          "\$"+eachFaveItem.price.toString(),
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
                                    "Tags:\n "+"\#"+eachFaveItem.tags.toString().replaceAll("[", "").replaceAll("]", ""),
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
                                eachFaveItem.image!,
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
                  "No favorite items added",
                ),
              );
            }
          }
      );
    }

}
