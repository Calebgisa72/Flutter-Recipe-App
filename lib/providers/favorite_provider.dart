import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favoriteIds => _favoriteIds;

  late String userId;

  Set<String> _loadingIds = {};

  FavoriteProvider() {
    initializeFavorite();
  }

  void initializeFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('uid')!;
    await loadFavorite();
  }

  bool isLoading(String id) => _loadingIds.contains(id);

  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;

    _loadingIds.add(productId);
    notifyListeners();

    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      await addFavorite(productId);
    }

    _loadingIds.remove(productId);
    notifyListeners();
  }

  bool alreadyFav(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  Future<void> addFavorite(String productId) async {

    try {
      DocumentReference ref = _firestore
          .collection('UserFavorite')
          .doc(productId);
      await ref.set({
        'favoriteBy': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Add Favorite Error: $e');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      DocumentReference ref = _firestore
          .collection('UserFavorite')
          .doc(productId);
      await ref.set({
        'favoriteBy': FieldValue.arrayRemove([userId]),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Remove Favorite Error: $e');
    }
  }

  Future<void> loadFavorite() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('UserFavorite').get();

      _favoriteIds =
          snapshot.docs
              .where((doc) {
                List? favoriteBy = doc['favoriteBy'];
                return favoriteBy != null && favoriteBy.contains(userId);
              })
              .map((doc) => doc.id)
              .toList();
    } catch (e) {
      print('Load Favorite Error: $e');
    }
    notifyListeners();
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
