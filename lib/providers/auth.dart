import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/http_exception.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SignInMode { Google, Email }

class Auth with ChangeNotifier {
  var user;
  SignInMode signInMode = SignInMode.Email;
  var _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    // if (_expiryDate != null &&
    //     _expiryDate.isAfter(DateTime.now()) &&
    //     _token != null) {
    //   return _token;
    // }
    return _token;
  }

  String get userId {
    return _userId;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();

  Future<void> authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDtsa4OJbgCZLrAHt6AcRURvyO3pBHDO7I';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);
      print(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));

      notifyListeners();
      final pref = await SharedPreferences.getInstance();
      final _userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      // autoLogout();
      pref.setString('userData', _userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  Future<FirebaseUser> googleSignIn() async {
    GoogleSignInAccount _googleSignInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication gsA = await _googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: gsA.accessToken,
      idToken: gsA.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser _user = authResult.user;
    signInMode = SignInMode.Google;
    _token = gsA.accessToken;
    print(_token);

    notifyListeners();
    user = _user.displayName;
    print("User Name: ${_user.displayName}");
    return _user;
  }

  Future<bool> tryAutoLogin() async {
    final pref = await SharedPreferences.getInstance();

    if (!pref.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(pref.getString('userData')) as Map<String, Object>;

    final expiryDate2 = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate2.isBefore(DateTime.now())) {
      return false;
    }

    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate2;
    _token = extractedUserData['token'];
    // autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _expiryDate = null;
    notifyListeners();
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    final pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  // void autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer.cancel();
  //   }
  //   final _timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: 6), logout);
  // }
}
