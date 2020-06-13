import 'package:flutter/material.dart';
import 'package:kitchen/authentication/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerMenu extends StatelessWidget {
  final String staffName;
  final String staffId;
  final String restaurantName;
  DrawerMenu({
    this.staffName,
    this.staffId,
    this.restaurantName,
  });

  clearData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        DrawerHeader(
          child: Column(
            children: <Widget>[
              Text(restaurantName),
              Text("Hey ! $staffName "),
            ],
          ),
        ),

//        FlatButton(
//          child: Center(
//            child: Text('Assigned Tables'),
//          ),
//          onPressed: () {
//            Navigator.of(context).pop();
//            Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) => AssignedTables(
//                  restaurant: restaurant,
//                  staffId: staffId,
//                ),
//              ),
//            );
//          },
//        ),

//        Divider(),

        FlatButton(
          child: Center(
            child: Text('Logout'),
          ),
          onPressed: () {
            clearData();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          },
        ),
        ///////////////////
      ],
    );
  }
}
