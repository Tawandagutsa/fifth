import 'package:fifth/providers/pollurl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pay.dart';
import '../providers/pollurl.dart';
import '../providers/orders.dart';

class PhoneNumber extends StatelessWidget {
  static const routeName = '/phoneNumber';

  @override
  Widget build(BuildContext context) {
    final appTitle = '';

    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  String flag;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            controller: _controller,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.startsWith("077") ||
                    _controller.text.startsWith("+26377")) {
                  flag = "1";
                  Provider.of<Pay>(context, listen: false)
                      .pay(_controller.text, context, flag);
                } else if (_controller.text.startsWith("071") ||
                    _controller.text.startsWith("+26371")) {
                  flag = "2";
                  Provider.of<Pay>(context, listen: false)
                      .pay(_controller.text, context, flag);
                } else {
                  //Invalid number
                }
              },
              child: Text('Pay'),
            ),
          ),
        ],
      ),
    );
  }
}
