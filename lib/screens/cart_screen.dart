import 'package:fifth/providers/product.dart';
import 'package:fifth/screens/phoneNumber.dart';
import 'package:flutter/material.dart';
import '../providers/cart.dart' show Cart;
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart';
import '../providers/orders.dart';
import '../widgets/CustomShowDialog.dart';
import 'package:paynow/paynow.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import '../providers/products.dart';
import '../providers/pay.dart';
import '../screens/phoneNumber.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    final mq = MediaQuery.of(context);

    void ShowDialog(BuildContext context) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController _phoneNumber = TextEditingController();
            return CustomAlertDialog(
              content: Container(
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.width / 1,
                color: Colors.white,
                child: Center(
                    // Center is a layout widget. It takes a single child and positions it
                    // in the middle of the parent.
                    child: Column(
                  // Column is also a layout widget. It takes a list of children and
                  // arranges them vertically. By default, it sizes itself to fit its
                  // children horizontally, and tries to be as tall as its parent.
                  //
                  // Invoke "debug painting" (press "p" in the console, choose the
                  // "Toggle Debug Paint" action from the Flutter Inspector in Android
                  // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                  // to see the wireframe for each widget.
                  //
                  // Column has various properties to control how it sizes itself and
                  // how it positions its children. Here we use mainAxisAlignment to
                  // center the children vertically; the main axis here is the vertical
                  // axis because Columns are vertical (the cross axis would be
                  // horizontal).

                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                          icon: Icon(Icons.phone),
                          hintText: "Phone Number",
                          hintStyle: TextStyle(color: Colors.black12)),
                      cursorColor: Colors.black12,
                      keyboardType: TextInputType.phone,
                      controller: _phoneNumber,
                    ),
                    Divider(),
                    // ArgonTimerButton(
                    //   height: 50,
                    //   width: MediaQuery.of(context).size.width * 0.45,
                    //   minWidth: MediaQuery.of(context).size.width * 0.30,
                    //   highlightColor: Colors.transparent,
                    //   highlightElevation: 0,
                    //   roundLoadingShape: false,
                    //   onTap: (startTimer, btnState) {
                    //     if (btnState == ButtonState.Idle) {
                    //       startTimer(15);
                    //     }

                    // Paynow paynow = Paynow(
                    //     integrationKey:
                    //         "95ae25f9-b11f-4ad6-8b6e-e9e42838418c",
                    //     integrationId: "11326",
                    //     returnUrl: "http://google.com",
                    //     resultUrl: "http://google.com");
                    // Payment payment = paynow.createPayment(
                    //     "user", "tawandagutsa@outlook.com");

                    // payment.add("Order", cart.totalAmount);

                    // // Initiate Mobile Payment
                    // paynow.sendMobile(payment, _phoneNumber.text)
                    //   ..then((InitResponse response) {
                    //     // display results
                    //     print(response());
                    //     Future.delayed(Duration(seconds: 20 ~/ 2));
                    //     // Check Transaction status from pollUrl
                    //     paynow.checkTransactionStatus(response.pollUrl)
                    //       ..then((StatusResponse status) {
                    //         print(status.paid);
                    //         cart.clear();
                    //       });
                    // });

                    // child: Text(
                    //   "PAY",
                    //   style: TextStyle(
                    //       color: Colors.white,
                    //       fontSi       // },ze: 18,
                    //       fontWeight: FontWeight.w700),
                    // ),
                    // loader: (timeLeft) {
                    //   return Text(
                    //     "Wait | $timeLeft",
                    //     style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.w700),
                    //   );
                    // },
                    // borderRadius: 5.0,
                    // color: Colors.greenAccent,
                    // elevation: 0,
                    // borderSide: BorderSide(color: Colors.black, width: 1.5),
                    // ),
                  ],
                )),
              ),
            );
          });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Cart'),
        ),
        body: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Total',
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      SizedBox(width: 10),
                      Chip(
                        label: Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      OrderButton(cart: cart)
                    ]),
              ),
            ),
            SizedBox(height: 13),
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (ctx, i) => CartItem(
                    cart.items.values.toList()[i].id,
                    cart.items.keys.toList()[i],
                    cart.items.values.toList()[i].price,
                    cart.items.values.toList()[i].quanitity,
                    cart.items.values.toList()[i].title),
              ),
            )
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: (widget.cart.totalAmount <= 0.0 || _isLoading)
          ? null
          : () async {
              // // ShowDialog(context);
              // setState(() {
              //   _isLoading = true;
              // });
              // await Provider.of<Orders>(context, listen: false).addOrder(
              //     widget.cart.items.values.toList(), widget.cart.totalAmount);
              // setState(() {
              //   _isLoading = false;
              // });
              //  .cart.clear();
              _modalBottom(context);
            },
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      textColor: Theme.of(context).primaryColor,
    );
  }

  void _modalBottom(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
              height: MediaQuery.of(context).size.height * .60,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Payment method",
                            style: TextStyle(fontSize: 30),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: 25,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                      Card(
                          child: ListTile(
                        leading: FlutterLogo(),
                        title: Text('Ecocash'),
                        onTap: () => Navigator.of(context)
                            .pushNamed(PhoneNumber.routeName),
                      )),
                      Card(
                          child: ListTile(
                        leading: FlutterLogo(),
                        title: Text('OneMoney'),
                        onTap: () => Navigator.of(context)
                            .pushNamed(PhoneNumber.routeName),
                      )),
                      Card(
                          child: ListTile(
                        leading: FlutterLogo(),
                        title: Text('USD'),
                        onTap: () => print("USD"),
                      )),
                    ],
                  )));
        });
  }
}
