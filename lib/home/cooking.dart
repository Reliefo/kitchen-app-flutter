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
                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF5DEB5),
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
//
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                cookingOrders[index].table ?? " ",
                                style: kHeaderStyleSmall,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
//
                                formatDate(
                                      (cookingOrders[index].timeStamp),
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
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffEFEEEF),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(6.0),
                                    ),
                                  ),
                                  padding: EdgeInsets.only(
                                      left: 8, top: 8, right: 0, bottom: 2),
                                  margin: EdgeInsets.all(4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child:
                                              // for checking instructions
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${cookingOrders[index].orders[index2].foodList[index3].name} x ${cookingOrders[index].orders[index2].foodList[index3].quantity}' ??
                                                    " ",
                                                style: kTitleStyle,
                                              ),
                                              cookingOrders[index]
                                                          .orders[index2]
                                                          .foodList[index3]
                                                          .foodOption !=
                                                      null
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      primary: false,
                                                      itemCount:
                                                          cookingOrders[index]
                                                              .orders[index2]
                                                              .foodList[index3]
                                                              .foodOption
                                                              .options
                                                              .length,
                                                      itemBuilder:
                                                          (context, index4) {
                                                        return Text(
                                                          '${cookingOrders[index].orders[index2].foodList[index3].foodOption.options[index4]['option_name']}' ??
                                                              " ",
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      width: 0, height: 0),
                                              cookingOrders[index]
                                                          .orders[index2]
                                                          .foodList[index3]
                                                          .foodOption !=
                                                      null
                                                  ? ListView.builder(
                                                      shrinkWrap: true,
                                                      primary: false,
                                                      itemCount:
                                                          cookingOrders[index]
                                                              .orders[index2]
                                                              .foodList[index3]
                                                              .foodOption
                                                              .choices
                                                              .length,
                                                      itemBuilder:
                                                          (context, index4) {
                                                        return Text(
                                                          '${cookingOrders[index].orders[index2].foodList[index3].foodOption.choices[index4]}' ??
                                                              " ",
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      width: 0, height: 0),
                                              cookingOrders[index]
                                                          .orders[index2]
                                                          .foodList[index3]
                                                          .instructions ==
                                                      null
                                                  ? Container(
                                                      width: 0, height: 0)
                                                  : Text(
                                                      cookingOrders[index]
                                                              .orders[index2]
                                                              .foodList[index3]
                                                              .instructions ??
                                                          " ",
                                                      style: kSubTitleStyle,
                                                    ),
                                            ],
                                          ),
                                        ),
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
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ),
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
        : Container(
            height: MediaQuery.of(context).size.height * 0.30,
            child: Center(
              child: Text("Nothing to cook", style: kHeaderStyleSmall),
            ),
          );
  }
}
