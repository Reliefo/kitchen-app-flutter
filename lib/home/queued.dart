import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitchen/constants.dart';
import 'package:kitchen/data.dart';

class Queued extends StatelessWidget {
  final List<TableOrder> queueOrders;
  final Function updateOrders;

  Queued({@required this.queueOrders, this.updateOrders});

  @override
  Widget build(BuildContext context) {
    return queueOrders.length > 0
        ? Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: queueOrders.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
                            'Table : ${queueOrders[index].table}' ?? " ",
                            style: homePageS1,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
//
                            'Arrival Time : ${formatDate(
                                  (queueOrders[index].timeStamp),
                                  [HH, ':', nn],
                                )}' ??
                                " ",
                            style: homePageS3,
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      primary: false,
                      itemCount: queueOrders[index].orders.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index2) {
                        return ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: queueOrders[index]
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
                                      padding: EdgeInsets.fromLTRB(16, 6, 0, 6),
                                      child:
// for checking instructions
                                          queueOrders[index]
                                                      .orders[index2]
                                                      .foodList[index3]
                                                      .instructions ==
                                                  "no"
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${queueOrders[index].orders[index2].foodList[index3].name} x ${queueOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                          " ",
//
                                                      style: homePageS3,
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${queueOrders[index].orders[index2].foodList[index3].name} x ${queueOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                          " ",
//
                                                      style: homePageS3,
                                                    ),

// for checking instructions

                                                    Text(
                                                      queueOrders[index]
                                                              .orders[index2]
                                                              .foodList[index3]
                                                              .instructions ??
                                                          " ",
                                                    ),
                                                  ],
                                                ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        updateOrders(
                                          queueOrders[index].oId,
                                          queueOrders[index].orders[index2].oId,
                                          queueOrders[index]
                                              .orders[index2]
                                              .foodList[index3]
                                              .foodId,
                                          "cooking",
                                        );

//Todo: send item to cooking list insted of queue orders

                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text(' added to cooking')));
                                      },
                                    ),
                                  )
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
          )

        // display when there in nothing in the queue
//            : Expanded(
//                child: Container(
//                  width: double.maxFinite,
//                  child: Column(
//                    children: <Widget>[
//                      Expanded(
//                        child: Padding(
//                          padding: const EdgeInsets.all(20.0),
//                          child: Image.asset(
//                            'assets/icons/plate.png',
//                          ),
//                        ),
//                      ),
//                      Expanded(
//                        child: Center(
//                          child: Text(
//                            'No Orders Yet',
//                            style: homePageS4,
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ),

        : Flexible(
            fit: FlexFit.loose,
            child: Text("nothing in cooking"),
          );
  }
}

//
//ListTile(
//                                    title: Text(
//                                      '${queueOrders[index].orders[index2].foodlist[index3].name} x '
//                                              '${queueOrders[index].orders[index2].foodlist[index3].quantity}' ??
//                                          " ",
////
//                                      style: homePageS3,
//                                    ),
//                                    subtitle: queueOrders[index]
//                                                .orders[index2]
//                                                .foodlist[index3]
//                                                .instructions ==
//                                            "no"
//                                        ? null
//                                        : Text(
//                                            queueOrders[index]
//                                                    .orders[index2]
//                                                    .foodlist[index3]
//                                                    .instructions ??
//                                                " ",
//                                          ),
//                                    trailing: IconButton(
//                                      icon: Icon(Icons.add),
//                                      onPressed: () {
//                                        updateOrders(
//                                          queueOrders[index].oId,
//                                          queueOrders[index].orders[index2].oId,
//                                          queueOrders[index]
//                                              .orders[index2]
//                                              .foodlist[index3]
//                                              .foodId,
//                                          "cooking",
//                                        );
//
////Todo: send item to cooking list insted of queue orders
//
//                                        Scaffold.of(context).showSnackBar(
//                                            SnackBar(
//                                                content:
//                                                    Text(' added to cooking')));
//                                      },
//                                    ),
//                                  );
