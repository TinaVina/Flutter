class API
{
  //IPv4 needs to be changed in order to work
  static const hostConnect="http://172.16.1.158/api_furniture_store_app";//connection to our api service
  static const hostConnectUser="$hostConnect/user";
  static const hostConnectAdmin="$hostConnect/admin";
  static const hostConnectItems="$hostConnect/items";
  static const hostConnectTrending="$hostConnect/furniture";
  static const hostCart="$hostConnect/cart";
  static const hostFavorite="$hostConnect/favorite";

  //signup or login user
  static const validateEmail= "$hostConnectUser/validate_email.php";
  static const signUp= "$hostConnectUser/signup.php";
  static const login= "$hostConnectUser/login.php";

  //login admin
  static const adminLogin= "$hostConnectAdmin/login.php";

  //upload and search for item
  static const uploadNewItem= "$hostConnectItems/upload.php";
  static const searchItems= "$hostConnectItems/search.php";

  //trending furniture
  static const getTrending= "$hostConnectTrending/trending.php";

  //newly added furniture
  static const getAllFurniture= "$hostConnectTrending/all.php";

  //cart
  static const addItemsToCart= "$hostCart/add.php";
  static const getCartList= "$hostCart/read.php";
  static const deleteSelectedItemsFromCart= "$hostCart/delete.php";
  static const updateSelectedItemsFromCart= "$hostCart/update.php";

  //favorites
  static const addFavorites= "$hostFavorite/add.php";
  static const deleteFavorites= "$hostFavorite/delete.php";
  static const validateFavorites= "$hostFavorite/validate_favorite.php";
  static const readFavorites= "$hostFavorite/read.php";

}