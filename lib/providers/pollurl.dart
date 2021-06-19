import 'package:flutter/cupertino.dart';

class PollUrl with ChangeNotifier {
  var error;
  var url;

  PollUrl({
    error,
    url,
  }) {
    this.error = error;
    this.url = url;
    notifyListeners();
  }

  String get urlpub {
    return url;
  }
}
