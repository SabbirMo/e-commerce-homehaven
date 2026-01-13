import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../home/model/home_model.dart';

class HomeController extends GetxController {
  var allItem = <HomeModel>[].obs;
  var filterItem = <HomeModel>[].obs;
  var searchQuery = ''.obs; // Add search query tracker

  final String mainDocId = "JbmCjuFy2CF90gyYW4tC";

  @override
  void onInit() {
    super.onInit();
    fetchAllProducts();
  }

  Future<void> fetchAllProducts() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('cetagories').doc(mainDocId);

      List<HomeModel> temp = [];

      // appliances
      var appliancesSnap = await docRef.collection('appliances').get();
      temp.addAll(appliancesSnap.docs
          .map((doc) => HomeModel.fromJson(doc.data()))
          .toList());

      // furniture
      var furnitureSnap = await docRef.collection('furniture').get();
      temp.addAll(furnitureSnap.docs
          .map((doc) => HomeModel.fromJson(doc.data()))
          .toList());

      // outdoor
      var outdoorSnap = await docRef.collection('outdoor').get();
      temp.addAll(outdoorSnap.docs
          .map((doc) => HomeModel.fromJson(doc.data()))
          .toList());

      // special
      var specialSnap = await docRef.collection('special').get();
      temp.addAll(specialSnap.docs
          .map((doc) => HomeModel.fromJson(doc.data()))
          .toList());

      allItem.value = temp;
      filterItem.value = temp;

      print("Total Products: ${allItem.length}");
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  /// specific category  data fatch
  Future<void> fetchCategoryProducts(String category) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(mainDocId)
          .collection(category) // appliances / furniture / outdoor / special
          .get();

      filterItem.value =
          snapshot.docs.map((doc) => HomeModel.fromJson(doc.data())).toList();

      print("Category $category fetched: ${filterItem.length}");
    } catch (e) {
      print("Error fetching $category: $e");
    }
  }

  /// Search filter
  void searchProduct(String query) {
    searchQuery.value = query; // Track current search query
    if (query.isEmpty) {
      filterItem.value = allItem;
    } else {
      filterItem.value = allItem.where((item) {
        return item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.description.toLowerCase().contains(query.toLowerCase()) ||
            item.category.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    print('Search results: ${filterItem.length} products found for "$query"');
  }
}
