import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> get favoriteIds => _favoriteIds;

  Set<String> _loadingIds = {};

  FavoriteProvider() {
    loadFavorite();
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
      await _firestore.collection('UserFavorite').doc(productId).set({
        "isFavorite": true,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      await _firestore.collection('UserFavorite').doc(productId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> loadFavorite() async {
    try {
      QuerySnapshot favSnapshot =
          await _firestore.collection('UserFavorite').get();
      _favoriteIds = favSnapshot.docs.map((fav) => fav.id).toList();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  static FavoriteProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<FavoriteProvider>(context, listen: listen);
  }
}
