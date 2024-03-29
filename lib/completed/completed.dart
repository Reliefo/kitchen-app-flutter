import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitchen/constants.dart';
import 'package:kitchen/data.dart';

class Completed extends StatelessWidget {
  Completed({@required this.completedOrders});

  final List<TableOrder> completedOrders;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                    color: kThemeColor,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.zero, bottom: Radius.circular(8))),
                padding: EdgeInsets.symmetric(vertical: 4),
                width: double.maxFinite,
                child: Center(
                  child: Text(
                    'Completed',
                    style: kHeaderStyle,
                  ),
                ),
              ),

              //to check if there is orders in queue or not
              completedOrders.length > 0
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: ListView.builder(
                          primary: false,
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: completedOrders.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Text(
                                        completedOrders[index].table ?? " ",
                                        style: kHeaderStyleSmall,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      child: Text(
//
                                        formatDate(
                                              (completedOrders[index]
                                                  .timeStamp),
                                              [HH, ':', nn],
                                            ) ??
                                            " ",
                                        style: kHeaderStyleSmall,
                                      ),
                                    ),
                                  ],
                                ),
                                ListView.builder(
                                  reverse: true,
                                  primary: false,
                                  itemCount:
                                      completedOrders[index].orders.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index2) {
                                    return ListView.builder(
                                        reverse: true,
                                        primary: false,
                                        shrinkWrap: true,
                                        itemCount: completedOrders[index]
                                            .orders[index2]
                                            .foodList
                                            .length,
                                        itemBuilder: (context, index3) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            16, 6, 0, 6),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          '${completedOrders[index].orders[index2].foodList[index3].name} x ${completedOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                              " ",
//
                                                          style: kTitleStyle,
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                                Divider(
                                  thickness: 2,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    )

                  // display when there in nothing in the queue
                  : Expanded(
                      child: Container(
                        width: double.maxFinite,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Image.asset(
                                  'assets/icons/plate.png',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'No Orders Completed',
                                  style: homePageS4,
                                ),
                              ),
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
