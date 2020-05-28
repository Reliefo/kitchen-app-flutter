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
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
//                  color: Colors.blueGrey,
                  child: ListView(
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                                color: kThemeColor,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.zero,
                                    bottom: Radius.circular(8))),
                            padding: EdgeInsets.symmetric(vertical: 4),
                            width: double.maxFinite,
                            child: Center(
                              child: Text(
                                'Cooking',
                                style: kHeaderStyle,
                              ),
                            ),
                          ),
                          Cooking(
                            cookingOrders: cookingOrders,
                            updateOrders: updateOrders,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: kThemeColor,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.zero,
                                    bottom: Radius.circular(8))),
                            padding: EdgeInsets.symmetric(vertical: 4),
                            width: double.maxFinite,
                            child: Center(
                              child: Text(
                                'Queued',
                                style: kHeaderStyle,
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
