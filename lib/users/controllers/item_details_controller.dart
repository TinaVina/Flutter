import 'package:get/get.dart';


class itemDetailsController extends GetxController
{

  RxInt _quantity=1.obs;
  RxInt _size=0.obs;
  RxInt _color=0.obs;
  RxBool _isFavorite=false.obs;

  int get quantity=>_quantity.value;
  int get size=>_size.value;
  int get color=>_color.value;
  bool get isFavorite=>_isFavorite.value;

  setQuantityItem(int quantitiy){
    _quantity.value=quantitiy;
  }

  setSizeItem(int size){
    _size.value=size;
  }

  setColorsItem(int color){
    _color.value=color;
  }

  setFavoriteItem(bool favorite){
    _isFavorite.value=favorite;
  }




}