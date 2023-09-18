import 'package:furniture_store_app/users/model/cart.dart';
import 'package:get/get.dart';


class CartListController extends GetxController
{
  RxList<cart> _cartlist = <cart>[].obs;
  RxList<int> _selectedItemList = <int>[].obs;
  RxBool _isSelectedAll = false.obs;
  RxDouble _total = 0.0.obs;

  List<cart> get cartList => _cartlist.value;
  List<int> get selectedItemList => _selectedItemList.value;
  bool get isSelectedAll => _isSelectedAll.value;
  double get total => _total.value;

  setList(List<cart> list)
  {
    _cartlist.value = list;
  }

  addSelectedItem(int selectedItemCartID)
  {
    _selectedItemList.value.add(selectedItemCartID);
    update();
  }

  deleteSelectedItem(int selectedItemCartID)
  {
    _selectedItemList.value.remove(selectedItemCartID);
    update();
  }

  setIsSelectedAllItems()
  {
    //true
    _isSelectedAll.value = !_isSelectedAll.value;
  }

  clearAllSelectedItems()
  {
    _selectedItemList.value.clear();
    update();
  }

  setTotal(double overallTotal)
  {
    _total.value = overallTotal;
  }
}