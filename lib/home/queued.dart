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
                return queueOrders[index] != null &&
                        queueOrders[index].orders.isNotEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: Color(0xffF5DEB5),
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      queueOrders[index].table ?? " ",
                                      style: kHeaderStyleSmall,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
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
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xffEFEEEF),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(6.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: 8,
                                            top: 8,
                                            right: 0,
                                            bottom: 2),
                                        margin: EdgeInsets.all(4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      '${queueOrders[index].orders[index2].foodList[index3].name} x ${queueOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                          " ",
                                                      style: kTitleStyle,
                                                    ),
                                                    queueOrders[index]
                                                                .orders[index2]
                                                                .foodList[
                                                                    index3]
                                                                .foodOption !=
                                                            null
                                                        ? ListView.builder(
                                                            shrinkWrap: true,
                                                            primary: false,
                                                            itemCount:
                                                                queueOrders[
                                                                        index]
                                                                    .orders[
                                                                        index2]
                                                                    .foodList[
                                                                        index3]
                                                                    .foodOption
                                                                    .options
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index4) {
                                                              return Text(
                                                                '${queueOrders[index].orders[index2].foodList[index3].foodOption.options[index4]['option_name']}' ??
                                                                    " ",
                                                              );
                                                            },
                                                          )
                                                        : Container(
                                                            width: 0,
                                                            height: 0),
                                                    queueOrders[index]
                                                                .orders[index2]
                                                                .foodList[
                                                                    index3]
                                                                .foodOption !=
                                                            null
                                                        ? ListView.builder(
                                                            shrinkWrap: true,
                                                            primary: false,
                                                            itemCount:
                                                                queueOrders[
                                                                        index]
                                                                    .orders[
                                                                        index2]
                                                                    .foodList[
                                                                        index3]
                                                                    .foodOption
                                                                    .choices
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index4) {
                                                              return Text(
                                                                '${queueOrders[index].orders[index2].foodList[index3].foodOption.choices[index4]}' ??
                                                                    " ",
                                                              );
                                                            },
                                                          )
                                                        : Container(
                                                            width: 0,
                                                            height: 0),
                                                    queueOrders[index]
                                                                .orders[index2]
                                                                .foodList[
                                                                    index3]
                                                                .instructions ==
                                                            null
                                                        ? Container(
                                                            width: 0, height: 0)
                                                        : Text(
                                                            queueOrders[index]
                                                                    .orders[
                                                                        index2]
                                                                    .foodList[
                                                                        index3]
                                                                    .instructions ??
                                                                " ",
                                                            style:
                                                                kSubTitleStyle,
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: IconButton(
                                                icon: Icon(Icons.add),
                                                onPressed: () {
                                                  updateOrders(
                                                    queueOrders[index].oId,
                                                    queueOrders[index]
                                                        .orders[index2]
                                                        .oId,
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
                                        ),
                                      );
                                    });
                              },
                            ),
                          ],
                        ),
                      )
                    : Container(height: 0, width: 0);
              },
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: Center(
              child: Text(
                "No Orders",
                style: kHeaderStyleSmall,
              ),
            ),
          );
  }
}
