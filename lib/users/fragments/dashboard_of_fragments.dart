import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:furniture_store_app/users/fragments/favorites_fragment_screen.dart';
import 'package:furniture_store_app/users/fragments/home_fragment_screen.dart';
import 'package:furniture_store_app/users/fragments/order_fragment_screen.dart';
import 'package:furniture_store_app/users/fragments/profile_fragment_screen.dart';
import 'package:furniture_store_app/users/userPreferences/current_user.dart';
import 'package:get/get.dart';

//connects all screens through a navigation bar
class DashboardOfFragments extends StatelessWidget
{
  CurrentUser _rememberCurrentUser= Get.put(CurrentUser());

  final List<Widget> _fragmentScreens=
  [
    HomeFragmentScreen(),
    FavoritesFragmentScreen(),
    OrderFragmentScreen(),
    ProfileFragmentScreen(),
  ];

  final  List _navigationButtonProperties =
  [
    {
      "activeIcon": Icons.home,
      "non_active_icon": Icons.home_outlined,
      "title": "Home",

    },
    {
    "activeIcon": Icons.favorite,
    "non_active_icon": Icons.favorite_border,
      "title": "Favorites",
    },
    {
      "activeIcon": FontAwesomeIcons.boxOpen,
      "non_active_icon": FontAwesomeIcons.box,
      "title": "Orders",
    },
    {
      "activeIcon": Icons.person,
      "non_active_icon": Icons.person_outline,
      "title": "Profile",
    },

  ];

  final RxInt _indexNumber=0.obs;

  @override
  Widget build(BuildContext context) {
    return GetBuilder
      (
      init: CurrentUser(),
      initState:(currentState)
      {
        _rememberCurrentUser.getUserInfo();
      },
      builder: (controller)
      {
        return Scaffold
          (
          body: SafeArea
            (
            child: Obx
              (
                ()=>_fragmentScreens[_indexNumber.value]
            ),
          ),
          backgroundColor: Colors.cyan.shade500,
          bottomNavigationBar: Obx
            (
              ()=> BottomNavigationBar
                (
                currentIndex: _indexNumber.value,
                onTap: (value)
                {
                  _indexNumber.value=value; //depending on the index number it will open the wanted screen
                },
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedItemColor: Colors.black38,
                unselectedItemColor: Colors.white,
                items: List.generate(4,(index) //for the 4 screens we have
              {
                var navBtnProperty= _navigationButtonProperties[index];
                return BottomNavigationBarItem
                  (
                  backgroundColor: Colors.blueGrey,
                  icon: Icon(navBtnProperty["non_active_icon"]),
                  activeIcon: Icon(navBtnProperty["activeIcon"]),
                  label: navBtnProperty["title"],
                );
              }
                ),
              ),
          ),
        );
      },
    );
  }
}

