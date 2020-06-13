import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/options.dart';
import 'package:flutter/material.dart';
import 'package:kitchen/completed/completed.dart';
import 'package:kitchen/data.dart';
import 'package:kitchen/drawer/drawerMenu.dart';
import 'package:kitchen/home/home.dart';
import 'package:kitchen/url.dart';

class Connection extends StatefulWidget {
  final String jwt;
  final String staffId;
  final String restaurantId;
  Connection({
    this.jwt,
    this.staffId,
    this.restaurantId,
  });
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection> {
  bool webSocketConnected = false;
  final loginIdController = new TextEditingController();
  final urlController = new TextEditingController();

  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  List<TableOrder> queueOrders = [];
  List<TableOrder> cookingOrders = [];
  List<TableOrder> completedOrders = [];
  Map<String, bool> _isProbablyConnected = {};
  String kitchenStaffName, restaurantName, kitchenId;
  @override
  void initState() {
    super.initState();

    manager = SocketIOManager();

    initSocket(uri);
  }

  initSocket(uri) async {
    print('hey from init');
//    print(loginSession.jwt);

    var identifier = 'working';
    SocketIO socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        uri,
        nameSpace: "/reliefo",
        //Query params - can be used for authentication
        query: {
          "jwt": widget.jwt,
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },
        //Enable or disable platform channel logging
        enableLogging: false,
        transports: [
          Transports.WEB_SOCKET /*, Transports.POLLING*/
        ] //Enable required transport

        ));
    socket.onConnect((data) {
      pprint({"Status": "connected..."});
      setState(() {
        webSocketConnected = true;
      });

      print("on Connected");
      print(data);

      socket.emit("check_logger", [" sending........."]);

      socket.emit("fetch_kitchen_details", [
        jsonEncode({
          "restaurant_id": widget.restaurantId,
          "kitchen_staff_id": widget.staffId
        })
      ]);
//      socket.emit("fetch_order_lists", [
//        jsonEncode({"restaurant_id": widget.restaurantId})
//      ]);
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect((data) {
      print('object disconnnecgts');
    });
    socket.on("logger", (data) => pprint(data));
    socket.on("restaurant_object", (data) => fetchRestaurantObject(data));
    socket.on("kitchen_staff_object", (data) => fetchStaffObject(data));
    socket.on("order_lists", (data) => fetchInitialLists(data));
    socket.on("new_orders", (data) => fetchNewOrders(data));
    socket.on("order_updates", (data) => fetchOrderUpdates(data));

    socket.connect();
    sockets[identifier] = socket;
  }

  disconnect(String identifier) async {
    await manager.clearInstance(sockets[identifier]);

    setState(() {
      webSocketConnected = false;
      _isProbablyConnected[identifier] = false;
    });
  }

  bool isProbablyConnected(String identifier) {
    return _isProbablyConnected[identifier] ?? false;
  }

  pprint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
    });
  }

  fetchRestaurantObject(data) {
    print("restaurant object");
    print(data['name']);

    restaurantName = data['name'];
  }

  fetchStaffObject(data) {
    print(data);

    if (data is Map) {
      data = json.encode(data);
    }
    var decoded = jsonDecode(data);
    print(decoded);
    setState(() {
      kitchenStaffName = decoded['name'];
      kitchenId = decoded['kitchen'];
    });
    print("fetchStaffObject not implimented completely");
  }

  fetchInitialLists(data) {
//    print("her inside fegtch initla lists");
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }

      queueOrders.clear();
      cookingOrders.clear();
      completedOrders.clear();

      var decoded = jsonDecode(data);
//      print("object");
      print(decoded.keys);
      print("queued");
      print(decoded['queue']);
      print("cooking");
      print(decoded['cooking']);
      print("completed");
      print(decoded['completed']);
      decoded["queue"].forEach((item) {
        print(item);
        TableOrder order = TableOrder.fromJson(item, kitchenId);

        queueOrders.add(order);
      });
      decoded["cooking"].forEach((item) {
        TableOrder order = TableOrder.fromJson(item, kitchenId);

        cookingOrders.add(order);
      });
      decoded["completed"].forEach((item) {
        TableOrder ord = TableOrder.fromJson(item, kitchenId);

        completedOrders.add(ord);
      });
    });
  }

  fetchNewOrders(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }

      print("New orders have come to the Queue");
      print(jsonDecode(data));

      TableOrder order = TableOrder.fromJson(jsonDecode(data), kitchenId);

      queueOrders.add(order);
    });
  }

  fetchOrderUpdates(data) {
    print('order update coming');
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      var decoded = jsonDecode(data);

      print(decoded);

      var selectedOrder;

      if (widget.staffId != decoded['kitchen_staff_id']) {
        if (decoded['type'] == "cooking") {
          selectedOrder = queueOrders;
        } else if (decoded['type'] == "completed") {
          selectedOrder = cookingOrders;
        }
        print('printing from updating');

        selectedOrder.forEach((tableorder) {
          print(tableorder.oId);
          if (tableorder.oId == decoded['table_order_id']) {
            print('table id  matched${decoded['food_id']}');
            tableorder.orders.forEach((order) {
              if (order.oId == decoded['order_id']) {
                print('order id  matched${decoded['food_id']}');
                order.foodList.forEach((fooditem) {
                  if (fooditem.foodId == decoded['food_id']) {
                    print('food id  matched${decoded['food_id']}');
                    fooditem.status = decoded['type'];
//                   push to cooking and completed orders
                    pushTo(tableorder, order, fooditem, decoded['type']);
                    print('coming here at leastsadf');

                    order.removeFoodItem(decoded['food_id']);
                    print('coming here at least');
                    tableorder.cleanOrders(order.oId);
                    if (tableorder.selfDestruct()) {
                      print('self destruct');

                      selectedOrder.removeWhere(
                          (taborder) => taborder.oId == tableorder.oId);
                    }
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  updateOrders(utableId, uorderId, ufoodId, utype) {
    SocketIO socket = sockets['working'];
    socket.emit("kitchen_updates", [
      {
        "table_order_id": utableId,
        "order_id": uorderId,
        "food_id": ufoodId,
        "type": utype,
        "kitchen_staff_id": widget.staffId
      }
    ]);
    setState(() {
      var toRemove = [];
      var selectedOrder;

      if (utype == "cooking") {
        selectedOrder = queueOrders;
      } else if (utype == "completed") {
        selectedOrder = cookingOrders;
      }

      selectedOrder.forEach((tableorder) {
        if (tableorder.oId == utableId) {
          tableorder.orders.forEach((order) {
            if (order.oId == uorderId) {
              order.foodList.forEach((fooditem) {
                if (fooditem.foodId == ufoodId) {
//                  print('all completed id  matched${utype}');
                  fooditem.status = utype;
                  // push to cooking and completed orders
                  pushTo(tableorder, order, fooditem, utype);
//                  print('coming here at leastsadf');

                  order.removeFoodItem(ufoodId);
//                  print('coming here at least');
                  tableorder.cleanOrders(order.oId);
                  if (tableorder.selfDestruct()) {
//                    print('self destruct');

                    selectedOrder.removeWhere(
                        (taborder) => taborder.oId == tableorder.oId);
                  }
                }
              });
            }
          });
        }
      });
    });
  }

  pushTo(table_order, order, food_item, type) {
    setState(() {
      var foundTable = false;
      var foundOrder = false;
      var pushingTo;
      if (type == "cooking") {
        pushingTo = cookingOrders;
      } else if (type == "completed") {
        pushingTo = completedOrders;
      }

      if (pushingTo.length == 0) {
        TableOrder tableOrder = TableOrder.fromJsonNew(table_order.toJson());
        Order currOrder = Order.fromJsonNew(order.toJson());
        currOrder.addFirstFood(food_item);

        tableOrder.addFirstOrder(currOrder);
        print(tableOrder.orders[0].foodList[0].name);
        pushingTo.add(tableOrder);
      } else {
        pushingTo.forEach((tableOrder) {
          if (table_order.oId == tableOrder.oId) {
            foundTable = true;
            tableOrder.orders.forEach((currOrder) {
              if (order.oId == currOrder.oId) {
                foundOrder = true;
                currOrder.addFood(food_item);
              }
            });
            if (!foundOrder) {
              Order currOrder = Order.fromJsonNew(order.toJson());
              currOrder.addFirstFood(food_item);

              tableOrder.addOrder(currOrder);
            }
          }
        });
        if (!foundTable) {
          TableOrder tableOrder = TableOrder.fromJsonNew(table_order.toJson());
          Order currOrder = Order.fromJsonNew(order.toJson());
          currOrder.addFirstFood(food_item);

          tableOrder.addFirstOrder(currOrder);
          print(tableOrder.orders[0].foodList[0].name);
          pushingTo.add(tableOrder);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
          child: DrawerMenu(
            staffId: widget.staffId,
            staffName: kitchenStaffName,
            restaurantName: restaurantName,
          ),
        ),
        body: webSocketConnected == true
            ? PageView(
                children: <Widget>[
                  HomePage(
                    cookingOrders: cookingOrders,
                    queueOrders: queueOrders,
                    updateOrders: updateOrders,
                  ),
                  Completed(
                    completedOrders: completedOrders,
                  ),
                ],
              )
            : Container(
                child: Center(
                  child: Text("Websocket not connected"),
                ),
              ),
      ),
    );
  }
}
