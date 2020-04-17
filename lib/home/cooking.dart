import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kitchen/constants.dart';
import 'package:kitchen/data.dart';

class Cooking extends StatelessWidget {
  final List<TableOrder> cookingOrders;
  final Function updateOrders;
  Cooking({@required this.cookingOrders, this.updateOrders});

  @override
  Widget build(BuildContext context) {
    return cookingOrders.length > 0
        ? Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: cookingOrders.length,
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
                            'Table :${cookingOrders[index].table}' ?? " ",
                            style: homePageS1,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text(
//
                            'Arrival Time : ${formatDate(
                                  (cookingOrders[index].timeStamp),
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
                      itemCount: cookingOrders[index].orders.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index2) {
                        return ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: cookingOrders[index]
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
                                            EdgeInsets.fromLTRB(16, 6, 0, 6),
                                        child:
                                            // for checking instructions
                                            cookingOrders[index]
                                                        .orders[index2]
                                                        .foodList[index3]
                                                        .instructions ==
                                                    "no"
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '${cookingOrders[index].orders[index2].foodList[index3].name} x ${cookingOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                            " ",
                                                        style: homePageS3,
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        '${cookingOrders[index].orders[index2].foodList[index3].name} x ${cookingOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                            " ",
                                                        style: homePageS3,
                                                      ),

                                                      // for checking instructions

                                                      Text(
                                                        cookingOrders[index]
                                                                .orders[index2]
                                                                .foodList[
                                                                    index3]
                                                                .instructions ??
                                                            " ",
                                                      ),
                                                    ],
                                                  )),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: IconButton(
                                      icon: Icon(Icons.done),
                                      onPressed: () {
                                        updateOrders(
                                          cookingOrders[index].oId,
                                          cookingOrders[index]
                                              .orders[index2]
                                              .oId,
                                          cookingOrders[index]
                                              .orders[index2]
                                              .foodList[index3]
                                              .foodId,
                                          "completed",
                                        );
                                        //Todo: send item to cooking list insted of queue orders

                                        Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "item added to cooking")));
                                      },
                                    ),
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
          )

        // display when there in nothing in the queue
//        : Expanded(
//            child: Container(
//              width: double.maxFinite,
//              child: Column(
//                children: <Widget>[
//                  Expanded(
//                    child: Padding(
//                      padding: const EdgeInsets.all(20.0),
//                      child: Image.asset(
//                        'assets/icons/plate.png',
//                      ),
//                    ),
//                  ),
//                  Expanded(
//                    child: Center(
//                      child: Text(
//                        'No Orders Yet',
//                        style: homePageS4,
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          );
        : Flexible(
            fit: FlexFit.loose,
            child: Text("nothing in cooking"),
          );
  }
}

//ListTile(
//title: Text(
//'${cookingOrders[index].orders[index2].foodlist[index3].name} x '
//'${cookingOrders[index].orders[index2].foodlist[index3].quantity}' ??
//" ",
////
//style: homePageS3,
//),
//subtitle: cookingOrders[index]
//.orders[index2]
//.foodlist[index3]
//.instructions ==
//"no"
//? null
//: Text(
//cookingOrders[index]
//.orders[index2]
//.foodlist[index3]
//.instructions ??
//" ",
//),
//trailing: IconButton(
//icon: Icon(Icons.done),
//onPressed: () {
//updateOrders(
//cookingOrders[index].oId,
//cookingOrders[index]
//    .orders[index2]
//    .oId,
//cookingOrders[index]
//    .orders[index2]
//    .foodlist[index3]
//    .foodId,
//"completed",
//);
//
////Todo: send item to cooking list insted of queue orders
//
//Scaffold.of(context).showSnackBar(
//SnackBar(
//content: Text(
//' added to completed')));
//},
//),
//);
