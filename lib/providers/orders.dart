import 'package:fifth/providers/cart.dart';
import 'package:fifth/providers/pay.dart';
import 'package:fifth/providers/pollurl.dart';
import 'package:flutter/cupertino.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pollurl.dart';
import 'package:provider/provider.dart';
import '../providers/pollurl.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  Map<String, dynamic> extractedData;
  List<String> list;
  var result;
  final List<dynamic> loadedProducts = [];
  String pollUrl;
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total,
      String status, PayMode payMode) async {
    final url =
        'https://projectdemo1-53590-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    await http
        .post(
          url,
          body: json.encode({
            'amount': total,
            'dateTime': timestamp.toString(),
            'paymentMethod':
                payMode == PayMode.Ecocash ? 'Ecocash' : 'Onemoney',
            'paymentStatus': status,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'quantity': cp.quanitity,
                      'price': cp.price,
                    })
                .toList(),
          }),
        )
        .then((value) => {
              _orders.insert(
                0,
                OrderItem(
                  id: json.decode(value.body)['name'],
                  amount: total,
                  dateTime: timestamp,
                  products: cartProducts,
                ),
              ),
              notifyListeners(),
            });
  }

  // Future<void> addOneOrder(List<CartItem> cartProducts, double total) async {
  //   final url =
  //       'https://projectdemo1-53590-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
  //   final timestamp = DateTime.now();
  //   await http
  //       .post(
  //         url,
  //         body: json.encode({
  //           'amount': total.toStringAsFixed(2),
  //           'dateTime': timestamp.toIso8601String(),
  //           'payment method': "oneMoney",
  //           'products': cartProducts
  //               .map((cp) => {
  //                     'id': cp.id,
  //                     'title': cp.title,
  //                     'quantity': cp.quanitity,
  //                     'price': cp.price,
  //                   })
  //               .toList(),
  //         }),
  //       )
  //       .then((value) => {
  //             _orders.insert(
  //               0,
  //               OrderItem(
  //                 id: json.decode(value.body)['name'],
  //                 amount: total,
  //                 dateTime: timestamp,
  //                 products: cartProducts,
  //               ),
  //             ),
  //             notifyListeners(),
  //           });
  // }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://projectdemo1-53590-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    var fetchedData = json.decode(response.body) as Map<String, dynamic>;
    if (fetchedData == null) {
      return;
    }

    final List<OrderItem> loadedOrders = [];
    fetchedData.forEach((orderId, orderDetail) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderDetail['amount'],
        products: (orderDetail['products'] as List<dynamic>)
            .map((item) => CartItem(
                id: item['id'],
                price: item['price'],
                quanitity: item['quantity'],
                title: item['title']))
            .toList(),
        dateTime: DateTime.parse(orderDetail['dateTime']),
      ));
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    });
  }

  void cancelOrder() {
    // cancel logic
  }

  Future<String> checkOrder(String pollUrl) async {
    String status;
    await http.post(pollUrl).then((response) {
      list = response.body.toString().split("&");
      if (list[3] == "status=Paid") {
        status = "Paid";
      } else if (list[3] == "status=Sent") {
        status = "Sent/No payment made";
      }
    });
    print("Payment status: " + status);

    return status;
  }
}
