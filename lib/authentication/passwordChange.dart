import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kitchen/authentication/loginPage.dart';
import 'package:kitchen/url.dart';

class PasswordChange extends StatefulWidget {
  final String username, password;
  PasswordChange({
    this.username,
    this.password,
  });
  @override
  _PasswordChangeState createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
//  String passChangeUrl = "http://192.168.0.9:5050/change_password";
  GlobalKey<FormState> _key = new GlobalKey();
  final TextEditingController _pass = TextEditingController();
  bool _validate = false;
  String confirmPassword, newPassword;
  int responseCode;

  @override
  Widget build(BuildContext context) {
    return responseCode == 200
        ? LoginPage()
        : Scaffold(
            appBar: AppBar(
              title: Text('Change Password'),
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(15.0),
                child: Form(
                  key: _key,
                  autovalidate: _validate,
                  child: formUI(),
                ),
              ),
            ),
          );
  }

  Widget formUI() {
    return Column(
      children: <Widget>[
//          SizedBox(
//            height: 150.0,
//            child: Image.network(
//              "http://pngimg.com/uploads/cannabis/cannabis_PNG75.png",
//              fit: BoxFit.contain,
//            ),
//          ),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "New Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          maxLength: 32,
          controller: _pass,
          validator: validatePassword,
          onSaved: (String val) {
            newPassword = val;
          },
        ),
        SizedBox(height: 12),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          maxLength: 32,
          validator: validateConfirmPassword,
          onSaved: (String val) {
            confirmPassword = val;
          },
        ),
        SizedBox(height: 15.0),
        RaisedButton(
          onPressed: _sendToServer,
          child: Text('Submit'),
        ),
      ],
    );
  }

  String validatePassword(String value) {
    //  Minimum 1 Upper case
//  Minimum 1 lowercase
//  Minimum 1 Numeric Number
//  Minimum 1 Special Character
//  Common Allow Character ( ! @ # $ & * ~ )

//    String pattern =
//        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
//    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      return "Password is Required";
    }

//    else if (!regExp.hasMatch(value)) {
//      return "Invalid Password";
//    }

    else {
      return null;
    }
  }

  String validateConfirmPassword(String value) {
//    String pattern = "^[a-zA-Z0-9]*\$";
//    RegExp regExp = RegExp(pattern);
    if (value.length == 0) {
      return "Password is Required";
    }

//    else if (!regExp.hasMatch(value)) {
//      return "Username must be a-z, A-Z and 0-9";
//    }
    else if (value != _pass.text) {
      return "Password does not match";
    }
    return null;
  }

  _sendToServer() {
    if (_key.currentState.validate()) {
      // No any error in validation
      _key.currentState.save();
      print("Password : $newPassword");
      print("Confirm Password : $confirmPassword");

      _makePostRequest(
          passChangeUrl, widget.username, widget.password, newPassword);
    } else {
      // validation error
      setState(() {
        _validate = true;
      });
    }
  }

  _makePostRequest(String url, String username, String oldPassword,
      String newPassword) async {
    // set up POST request arguments

//    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> json = {
      "username": username,
      "old_password": oldPassword,
      "new_password": newPassword
    };
    // make POST request
    print("json $json");
    http.Response response = await http.post(url, body: json);
    // check the status code for the result
    int statusCode = response.statusCode;
    // this API passes back the id of the new item added to the body
    String body = response.body;
    print("status code");
    if (statusCode == 200) {
      setState(() {
        responseCode = 200;
      });
    }
    print(statusCode);
    print(" response body ");
    print(body);
    // {
    //   "title": "Hello",
    //   "body": "body text",
    //   "userId": 1,
    //   "id": 101
    // }
  }
}
