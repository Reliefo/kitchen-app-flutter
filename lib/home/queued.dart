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
                            queueOrders[index].table ?? " ",
                            style: kHeaderStyleSmall,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
//
                            formatDate(
                                  (queueOrders[index].timeStamp),
                                  [HH, ':', nn],
                                ) ??
                                " ",
                            style: kHeaderStyleSmall,
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

                                          Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${queueOrders[index].orders[index2].foodList[index3].name} x ${queueOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                " ",
//
                                            style: kTitleStyle,
                                          ),
                                          queueOrders[index]
                                                      .orders[index2]
                                                      .foodList[index3]
                                                      .instructions ==
                                                  null
                                              ? Container(width: 0, height: 0)
                                              : Text(
                                                  queueOrders[index]
                                                          .orders[index2]
                                                          .foodList[index3]
                                                          .instructions ??
                                                      " ",
                                                  style: kSubTitleStyle,
                                                ),
                                          queueOrders[index]
                                                      .orders[index2]
                                                      .foodList[index3]
                                                      .foodOption !=
                                                  null
                                              ? ListView.builder(
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  itemCount: queueOrders[index]
                                                      .orders[index2]
                                                      .foodList[index3]
                                                      .foodOption
                                                      .options
                                                      .length,
                                                  itemBuilder:
                                                      (context, index4) {
                                                    return Text(
                                                      '${queueOrders[index].orders[index2].foodList[index3].foodOption.options[index4]['option_name']}' ??
                                                          " ",
                                                    );
                                                  },
                                                )
                                              : Container(width: 0, height: 0),
                                          queueOrders[index]
                                                      .orders[index2]
                                                      .foodList[index3]
                                                      .foodOption !=
                                                  null
                                              ? ListView.builder(
                                                  shrinkWrap: true,
                                                  primary: false,
                                                  itemCount: queueOrders[index]
                                                      .orders[index2]
                                                      .foodList[index3]
                                                      .foodOption
                                                      .choices
                                                      .length,
                                                  itemBuilder:
                                                      (context, index4) {
                                                    return Text(
                                                      '${queueOrders[index].orders[index2].foodList[index3].foodOption.choices[index4]}' ??
                                                          " ",
                                                    );
                                                  },
                                                )
                                              : Container(width: 0, height: 0),
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
        : Flexible(
            fit: FlexFit.loose,
            child: Text("nothing in cooking"),
          );
  }
}
