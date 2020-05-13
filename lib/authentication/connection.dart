import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/options.dart';
import 'package:flutter/material.dart';
import 'package:kitchen/completed/completed.dart';
import 'package:kitchen/data.dart';
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
//  String uri =
//      "http://ec2-13-232-202-63.ap-south-1.compute.amazonaws.com:5050/";
  bool webSocketConnected = false;
  final loginIdController = new TextEditingController();
  final urlController = new TextEditingController();

  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  List<TableOrder> queueOrders = [];
  List<TableOrder> cookingOrders = [];
  Map<String, bool> _isProbablyConnected = {};
  List<TableOrder> completedOrders = [];

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
      socket.emit("fetch_order_lists", ["arguments"]);
    });
    socket.onConnectError(pprint);
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onDisconnect((data) {
      print('object disconnnecgts');
    });
    socket.on("logger", (data) => pprint(data));

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
        TableOrder order = TableOrder.fromJson(item);

        queueOrders.add(order);
      });
      decoded["cooking"].forEach((item) {
        TableOrder order = TableOrder.fromJson(item);

        cookingOrders.add(order);
      });
      decoded["completed"].forEach((item) {
        TableOrder ord = TableOrder.fromJson(item);

        completedOrders.add(ord);
      });
    });
  }

  fetchNewOrders(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }

//      print("New orders have come to the Queue");
//      print(jsonDecode(data));

      TableOrder order = TableOrder.fromJson(jsonDecode(data));

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

      if (widget.staffId != decoded['kitchen_app_id']) {
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
        "kitchen_app_id": widget.staffId
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
    print(widget.staffId);
//    print("Alert when not null");
//    print(loginSession.headers['Authorization']);
    return MaterialApp(
        home: Scaffold(
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
//      drawer: Drawer(
//        child: ListView(
//          children: <Widget>[
//            DrawerHeader(
//              child: Column(
//                children: <Widget>[
//                  Container(
//                    child: Text('ID : $loginId'),
//                  ),
//                  Container(
//                    child: Text('URL : $URI'),
//                  ),
//                ],
//              ),
//            ),
//            Container(
//              child: TextFormField(
//                controller: loginIdController,
//                decoration: InputDecoration(
//                  labelText: "Enter Login id",
//                  fillColor: Colors.white,
//                  border: OutlineInputBorder(
//                    borderRadius: BorderRadius.circular(12.0),
//                  ),
//                  //fillColor: Colors.green
//                ),
//                keyboardType: TextInputType.text,
//              ),
//            ),
//            Container(
//              color: Colors.black26,
//              child: FlatButton(
//                child: Text('submit login id'),
//                onPressed: () {
////                  _saveData();
//                },
//              ),
//            ),
//            Divider(),
////            Container(
////              child: TextFormField(
////                controller: urlController,
////                decoration: InputDecoration(
////                  labelText: "Enter url",
////                  fillColor: Colors.white,
////                  border: OutlineInputBorder(
////                    borderRadius: BorderRadius.circular(12.0),
////                  ),
////                  //fillColor: Colors.green
////                ),
////                keyboardType: TextInputType.text,
////              ),
////            ),
////            Container(
////              color: Colors.black26,
////              child: FlatButton(
////                child: Text('submit url'),
////                onPressed: () {
////                  _saveData();
//////                  _getDataFromSaved();
////                },
////              ),
////            ),
//
//            Divider(),
//            ///////////////////
//
//            FlatButton(
//              child: Text('login'),
//              onPressed: () {
////                login();
//              },
//            ),
//            FlatButton(
//              child: Text('get'),
//              onPressed: () {
////                get_rest();
//              },
//            ),
//
//            FlatButton(
//              child: Text('Logout'),
//              onPressed: () {
//                setState(() {
//                  webSocketConnected = false;
//                });
//
//                disconnect('working');
//              },
//            ),
//          ],
//        ),
//      ),
    ));
  }
}
//{
//  String uri = "http://192.168.0.9:5050/";
//
////  String uri =
////      "http://ec2-13-232-202-63.ap-south-1.compute.amazonaws.com:5050/";
//
//  SocketIOManager manager;
//  Map<String, SocketIO> sockets = {};
//
//  List<Map<String, dynamic>> notificationData = [];
//  List<Map<String, dynamic>> history = [];
//
//  Restaurant restaurant = Restaurant();
//  final FirebaseMessaging _messaging = new FirebaseMessaging();
//
//  @override
//  void initState() {
//    manager = SocketIOManager();
////    loginSession = new Session();
////    login();
//    initSocket(uri);
//    printToken();
//    configureFirebaseListeners();
//    super.initState();
//  }
//
//  printToken() {
//    _messaging.getToken().then((token) {
//      print("token:   $token");
//    });
//  }
//
//  static int i = 0;
//
//  configureFirebaseListeners() {
//    _messaging.configure(
//      onMessage: (Map<String, dynamic> message) async {
//        if (i % 2 == 0) {
//          print('on message $message');
//          fetchRequests(message);
//          // something else you wanna execute
//        }
//        i++;
//      },
//      onResume: (Map<String, dynamic> message) async {
//        if (i % 2 == 0) {
//          print('on resume $message');
//          fetchRequests(message);
//        }
//        i++;
//      },
//      onLaunch: (Map<String, dynamic> message) async {
//        print('on launch $message');
//        fetchRequests(message);
//      },
//    );
//  }
//
////  login() async {
////    var output = await loginSession
////        .post(loginUri, {"username": "SID001", "password": "password123"});
////    print("I am loggin in ");
////    initSocket(uri);
////    print(output);
////  }
//
//  initSocket(uri) async {
//    print('hey');
////    print(loginSession.jwt);
//    print(sockets.length);
//    var identifier = 'working';
//    SocketIO socket = await manager.createInstance(SocketOptions(
//        //Socket IO server URI
//        uri,
//        nameSpace: "/reliefo",
//        //Query params - can be used for authentication
//        query: {
//          "jwt": widget.jwt,
////          "username": loginSession.username,
//          "info": "new connection from adhara-socketio",
//          "timestamp": DateTime.now().toString()
//        },
//        //Enable or disable platform channel logging
//        enableLogging: false,
//        transports: [
//          Transports.WEB_SOCKET /*, Transports.POLLING*/
////          Transports.POLLING
//        ] //Enable required transport
//
//        ));
//    socket.onConnect((data) {
//      pprint({"Status": "connected..."});
////      pprint(data);
////      sendMessage("DEFAULT");
//      socket.emit("fetch_handshake", ["Hello world!"]);
//
//      socket.emit("fetch_staff_details", [
//        jsonEncode(
//            {"staff_id": widget.staffId, "restaurant_id": widget.restaurantId})
//      ]);
//    });
//
//    socket.onConnectError(pprint);
//    socket.onConnectTimeout(pprint);
//    socket.onError(pprint);
//    socket.onDisconnect((data) {
//      print('object disconnnecgts');
////      disconnect('working');
//    });
//    socket.on("fetch", (data) => pprint(data));
//    socket.on("hand_shake", (data) => shakeHands(data));
//
//    socket.on("restaurant_object", (data) => updateRestaurant(data));
//    socket.on("staff_details", (data) => fetchInitialData(data));
//    socket.on("assist", (data) => fetchRequestStatus(data));
//    socket.on("order_updates", (data) => fetchRequestStatus(data));
//
////    ""
//
//    socket.connect();
//    sockets[identifier] = socket;
//  }
//
//  shakeHands(data) {
//    print("HEREREHRAFNDOKSVOD");
//    if (data is Map) {
//      data = json.encode(data);
//    }
//
//    sockets['working'].emit('hand_shook', ["arg"]);
//  }
//
//  pprint(data) {
//    setState(() {
//      if (data is Map) {
//        data = json.encode(data);
//      }
//
//      print("prksnk");
//      print(data);
//    });
//  }
//
//  fetchInitialData(data) {
////    (_id, name, requests_queue, ..., order_history, rej_order_history)
//    if (data is Map) {
//      data = json.encode(data);
//    }
//
//    print("initial decoded data");
////I/flutter ( 4158): _id
////I/flutter ( 4158): name
////I/flutter ( 4158): requests_queue
////I/flutter ( 4158): assistance_history
////I/flutter ( 4158): rej_assistance_history
////I/flutter ( 4158): order_history
////I/flutter ( 4158): rej_order_history
//    var decoded = jsonDecode(data);
//    decoded['requests_queue'].forEach((v) {
//      fetchRequests({"data": v});
//    });
//
//    decoded['assistance_history'].forEach((v) {
//      print("assistance_history");
//      print(v);
//      fetchHistory(v);
//    });
//
//    decoded['rej_assistance_history'].forEach((v) {
//      print("rej_assistance_history");
//      print(v);
//      fetchHistory(v);
//    });
//    decoded['order_history'].forEach((v) {
//      print("order_history");
//      print(v);
//      fetchHistory(v);
//    });
//    decoded['rej_order_history'].forEach((v) {
//      print("rej_order_history");
//      print(v);
//      fetchHistory(v);
//    });
//  }
//
//  fetchHistory(data) {
////    print("inside History");
//
//    Map<String, dynamic> updateData = {};
//
//    data.forEach((k, v) => updateData[k.toString()] = v);
//
////    print(updateData);
//
//    setState(() {
//      history.add(updateData);
//    });
//  }
//
//  fetchRequests(data) {
//    print("inside fetchOrderUpdates");
//
//    Map<String, dynamic> updateData = {};
//
//    data['data'].forEach((k, v) => updateData[k.toString()] = v);
//
//    print(updateData);
//
//    setState(() {
//      notificationData.add(updateData);
//    });
//  }
////  fetchOrderUpdates(data) {
////    print("inside fetchOrderUpdates");
////    print(data['data'].runtimeType);
////    Map<String, dynamic> updateData = {};
//////    var decoded = jsonDecode(data['data']);
//////    print("decoded $decoded");
////    data['data'].forEach((k, v) => updateData[k.toString()] = v);
////
////    String tableName;
////    String foodName;
//////    print(updateData);
////
////    if (updateData['request_type'] == "pickup_request") {
////      print("here compl");
////      restaurant.tableOrders.forEach((tableOrder) {
////        if (tableOrder.oId == updateData['table_order_id']) {
////          print(tableOrder.oId);
////          tableName = tableOrder.table;
////          tableOrder.orders.forEach((order) {
////            if (updateData['order_id'] == order.oId) {
////              order.foodList.forEach((food) {
////                if (updateData['food_id'] == food.foodId) {
////                  foodName = food.name;
////                  print("here");
////
////                  updateData["table"] = tableName;
////                  updateData["food"] = foodName;
////                  setState(() {
////                    notificationData.add(updateData);
////                  });
////                }
////              });
////            }
////          });
////        }
////      });
////    }
//////    {assistance_req_id: 5eafa7a301ccfd3da8c6c1ff, table_id: 5ead65c8e1823a4f2132579c,
//////    user_id: 5eaf03840e993a2a64fcdf95, timestamp: 2020-05-04 10:56:59.773610,
//////    click_action: FLUTTER_NOTIFICATION_CLICK, request_type: assistance_request,
//////    assistance_type: ketchup}
////    if (updateData["request_type"] == "assistance_request") {
////      print("comingj");
////      restaurant.tables.forEach((table) {
////        print("coming here");
////        if (table.oid == updateData["table_id"]) {
////          tableName = table.name;
////          print("coming here $tableName");
////          updateData["table"] = tableName;
////          print("fddfd");
////          print(updateData);
////          setState(() {
////            notificationData.add(updateData);
////          });
////        }
////      });
////    }
////  }
//
//  fetchRequestStatus(data) {
//    if (data is Map) {
//      data = json.encode(data);
//    }
//
//    print("updated status");
//
//    var decoded = jsonDecode(data);
//    print(decoded);
//
//    if (decoded["request_type"] == "pickup_request") {
//      notificationData.forEach((notification) {
//        if (notification["request_type"] == "pickup_request") {
//          if (decoded["order_id"] == notification["order_id"] &&
//              decoded["food_id"] == notification["food_id"]) {
//            setState(() {
//              history.add(notification);
//              notificationData.remove(notification);
//            });
//          }
//        }
//      });
//    }
//    if (decoded["request_type"] == "assistance_request") {
//      notificationData.forEach((notification) {
//        if (notification["request_type"] == "assistance_request") {
//          if (decoded["assistance_req_id"] ==
//              notification["assistance_req_id"]) {
//            setState(() {
//              history.add(notification);
//              notificationData.remove(notification);
//            });
//          }
//        }
//      });
//    }
//  }
//
//  requestStatusUpdate(localData) {
//    var encode;
//    String restaurantId = restaurant.restaurantId;
//
//    localData["data"]["restaurant_id"] = restaurantId;
//    localData["data"]["staff_id"] = restaurant.staff[2].oid;
//    localData["data"]["status"] = localData["status"];
//    encode = jsonEncode(localData["data"]);
//    sockets['working'].emit('staff_acceptance', [encode]);
//  }
//
//  updateRestaurant(data) {
//    print("restaurant fetch");
//    setState(() {
//      if (data is Map) {
//        data = json.encode(data);
//      }
//
//      var decoded = jsonDecode(data);
////      print(decoded);
//      restaurant = Restaurant.fromJson(decoded);
//    });
//  }
//
////  {notification: {title: Assistance Request from table8, body: Someone asked for help from table8},
////  data: {assistance_req_id: 5eafa9c7f179757a61077d87, table_id: 5ead65c8e1823a4f2132579c,
////  user_id: 5eaf03840e993a2a64fcdf95, timestamp: 2020-05-04 11:06:07.148809,
////  click_action: FLUTTER_NOTIFICATION_CLICK, request_type: assistance_request, assistance_type: help}}
//  @override
//  Widget build(BuildContext context) {
//    print("conn page");
//    print(widget.restaurantId);
//    print(widget.staffId);
//    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      home: SafeArea(
//        child: Scaffold(
//          drawer: Drawer(
//            child: DrawerMenu(
//              restaurant: restaurant,
//            ),
//          ),
//          body:
////          PageView(
////            children: <Widget>[
//              HomePage(
//            notificationData: notificationData,
//            history: history,
//            requestStatusUpdate: requestStatusUpdate,
//          ),
////              HistoryPage(),
////            ],
////          ),
//        ),
//      ),
//    );
//  }
//}
