import 'package:fifth/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Products with ChangeNotifier {
  final authToken;
  var _extractedData;
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Lasagna',
    //   description: 'Lasagna is good!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://www.jessicagavin.com/wp-content/uploads/2017/07/meat-lasagna-1200.jpg',
    // ),
    // Product(
    //     id: 'p2',
    //     title: 'Rice',
    //     description: 'Rice is good!',
    //     price: 59.99,
    //     imageUrl:
    //         'https://www.jessicagavin.com/wp-content/uploads/2020/03/how-to-cook-rice-16-1200.jpg'),
    // Product(
    //   id: 'p3',
    //   title: 'Mac&cheese',
    //   description: 'Mac & cheese is good!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://www.willcookforsmiles.com/wp-content/uploads/2019/01/mac-and-cheese-5.jpg',
    // ),
  ];
  Products(this.authToken, this._items);
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProduct(BuildContext context) async {
    final _signInMode = Provider.of<Auth>(context, listen: false).signInMode;
    final url =
        'https://projectdemo1-53590-default-rtdb.firebaseio.com/products.json?${_signInMode == SignInMode.Email ? "auth" : "access_token"}=$authToken';

    try {
      final response = await http.get(url);
      _extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (_extractedData == null) {
        return;
      }
      final List<Product> loadedProducts = [];
      _extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['Description'],
          imageUrl: prodData['imageUrl'],
          price: prodData['Price'],
          isFavourite: prodData['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }



  //  List<Product> category(BuildContext context, String category) {

  //     final List<Product> loadedProducts = [];
  //     _extractedData.forEach((prodId, prodData) {
  //       if (prodData['category']==category){
  //          loadedProducts.add(Product(
  //             id: prodId,
  //             title: prodData['title'],
  //             description: prodData['Description'],
  //             imageUrl: prodData['imageUrl'],
  //             price: prodData['Price'],
  //             isFavourite: prodData['isFavorite'],
  //       ));
  //       }        
  //     });
  //     return loadedProducts;
  //   }
  }

