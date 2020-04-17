import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitchen/constants.dart';
import 'package:kitchen/data.dart';

import 'cooking.dart';
import 'queued.dart';

class HomePage extends StatelessWidget {
  final List<TableOrder> queueOrders;
  final List<TableOrder> cookingOrders;
  final Function updateOrders;

  HomePage({
    @required this.queueOrders,
    @required this.cookingOrders,
    @required this.updateOrders,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.grey,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.blueGrey,
                  child: ListView(
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            width: double.maxFinite,
                            color: Colors.black12,
                            child: Center(
                              child: Text(
                                'Cooking',
                                style: homePageS4,
                              ),
                            ),
                          ),
                          Cooking(
                            cookingOrders: cookingOrders,
                            updateOrders: updateOrders,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            width: double.maxFinite,
                            color: Colors.black12,
                            child: Center(
                              child: Text(
                                'Queued',
                                style: homePageS4,
                              ),
                            ),
                          ),
                          Queued(
                            queueOrders: queueOrders,
                            updateOrders: updateOrders,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
