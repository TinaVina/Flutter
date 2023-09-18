import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:furniture_store_app/api_connection/api_connection.dart';
import 'package:furniture_store_app/users/item/item_details_screen.dart';
import 'package:furniture_store_app/users/model/furniture.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import '../cart/cart_list_screen.dart';

class searchItem extends StatefulWidget {

  final String? searchKeywords;

  searchItem({this.searchKeywords,});

  @override
  State<searchItem> createState() => _searchItemState();
}

class _searchItemState extends State<searchItem> {

  TextEditingController searchController=TextEditingController();



  Future<List<Furniture>> getSearchItem()async
  {
    List<Furniture> furnitureSearchList=[];

    if(searchController.text!="")//user must type something
        {
      try{
        var res= await http.post(Uri.parse(API.searchItems),
            body: {
              "searchKeywords": searchController.text,
            }
        );

        if(res.statusCode==200){
          var resBodyOfSearchItems= jsonDecode(res.body);
          if(resBodyOfSearchItems['success']==true)
          {
            (resBodyOfSearchItems['FoundSearchedItem']as List).forEach((eachSearchedItem)
            {
              furnitureSearchList.add(Furniture.fromJson(eachSearchedItem));
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
    }
    return furnitureSearchList;

  }



  @override
  void initState()
  {
    super.initState();

    searchController.text=widget.searchKeywords!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: showSearchBar(),
        titleSpacing: 0,
        leading: IconButton(
          onPressed: (){
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SearchItemsWidget(context),
    );
  }

  Widget showSearchBar(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        style: const TextStyle(
            color: Colors.white),
        controller: searchController,
        decoration: InputDecoration(
          prefixIcon: IconButton(
            onPressed: ()
            {
              setState(() {

              });
            },
            icon: const Icon(
              Icons.search_sharp,
              color: Colors.white,
            ),
          ),
          hintText: "Search",
          hintStyle: const TextStyle(
              color: Colors.white,
              fontSize: 18),
          suffixIcon: IconButton(
            onPressed: (){

              Get.to(()=>CartListScreen());
            },
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.white38,
            ),
          ),
          border:const  OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Colors.white,

            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              width: 4,
              color: Colors.white,


            ),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.white,


            ),
          ),
        ),
      ),
    );
  }

  SearchItemsWidget(context){

    return FutureBuilder(
        future: getSearchItem(),
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
                "No items found",
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
                "Start searching",
              ),
            );
          }
        }
    );
  }

}

