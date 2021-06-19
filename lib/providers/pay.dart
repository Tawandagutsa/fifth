import 'package:fifth/providers/pollurl.dart';
import 'package:flutter/material.dart';
import 'package:paynow/paynow.dart';
import 'package:provider/provider.dart';
import 'cart.dart';
import 'orders.dart';
import 'dart:io';

enum PayMode { Ecocash, OneMoney }

class Pay with ChangeNotifier {
  PayMode _payMode;

  final List<dynamic> loadedProducts = [];

  void pay(String phoneNumber, BuildContext context, String flag) {
    if (flag == "1") {
      _payMode = PayMode.Ecocash;
    } else {
      _payMode = PayMode.OneMoney;
    }

    var cart = Provider.of<Cart>(context, listen: false);

    Paynow paynow = Paynow(
        integrationKey: "95ae25f9-b11f-4ad6-8b6e-e9e42838418c",
        integrationId: "11326",
        returnUrl: "http://google.com",
        resultUrl: "http://google.com");

    Payment payment = paynow.createPayment("user", "tawandagutsa@outlook.com");

    payment.add("Order", 1.00);

    // Initiate Mobile Payment
    paynow.sendMobile(payment, phoneNumber,
        method: _payMode == PayMode.Ecocash ? "ecocash" : "onemoney")
      ..then((response) async {
        sleep(const Duration(seconds: 20));

        String status = await Provider.of<Orders>(context, listen: false)
            .checkOrder(response.pollUrl);

        await Provider.of<Orders>(context, listen: false).addOrder(
            cart.items.values.toList(), cart.totalAmount, status, _payMode);

        PollUrl(error: response.error, url: response.pollUrl);

        // Future.delayed(Duration(seconds: 20 ~/ 2));
        // Check Transaction status from pollUrl
        // paynow.checkTransactionStatus(response.pollUrl);
        // ..then((StatusResponse status) {
        // print(status.paid);
        // cart.clear();
      });
  }
}
