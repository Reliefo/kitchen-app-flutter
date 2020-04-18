import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:adhara_socket_io/options.dart';
import 'package:flutter/material.dart';
import 'package:kitchen/completed/completed.dart';
import 'package:kitchen/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';
import 'session.dart';

void main() => runApp(MyApp());

//const String URI = "http://ec2-13-232-202-63.ap-south-1.compute.amazonaws.com:5050/";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool webSocketConnected = false;
  final loginIdController = new TextEditingController();
  final urlController = new TextEditingController();

  SocketIOManager manager;
  Map<String, SocketIO> sockets = {};
  List<TableOrder> queueOrders = [];
  List<TableOrder> cookingOrders = [];
  Map<String, bool> _isProbablyConnected = {};
  List<TableOrder> completedOrders = [];
  String loginId;
  String URI =
      "http://ec2-13-232-202-63.ap-south-1.compute.amazonaws.com:5050/";

  Session loginSession;
  @override
  void initState() {
    super.initState();

    loginSession = new Session();
    manager = SocketIOManager();

    login();
//    getURI();
//    initSocket(URI);
  }

  login() async {
    List<String> loginId_URL = await _getDataFromSaved();
    loginId = loginId_URL[1];
    print("login id: $loginId");
    var output = await loginSession.post(
        "http://ec2-13-232-202-63.ap-south-1.compute.amazonaws.com:5050/login",
        {"username": loginId, "password": "password123"});
    initSocket(URI);
    print(output['refresh_token']);
//    await _saveData(output['refresh_token']);
    print(output);
    if (output['code'] == '401') {
      print('auth faild');
    } else if (output['code'] == '202') {
      print('already logged in');
    } else if (output['code'] == '200') {
      print('loggedIn');

//      String URI = loginId_URL[0];

    }
  }

//  refresh() async {
//    List<String> loginId_URL = await _getDataFromSaved();
//    String savedUrl = loginId_URL[0];
//    loginId = loginId_URL[1];
//
//    String refreshToken = loginId_URL[2];
//    var status = await loginSession.post(
//        "http://192.168.0.9:5050/refresh", {"username": loginId},
//        refresh: refreshToken);
//
//    await _saveData();
//
//    print(status);
//    if (status['code'] == null) {
//      print("Error, couldnt get jwt token");
//    } else if (status['code'] == '200') {
//      initSocket(savedUrl);
//    }
//    return true;
//  }

//  get_rest() async {
//    var output = await loginSession.get("http://192.168.0.9:5050/rest");
//    print(output);
//  }

  Future<List<String>> _getDataFromSaved() async {
    print("getData");
    final prefs = await SharedPreferences.getInstance();
    final pre = await SharedPreferences.getInstance();
//    final ref = await SharedPreferences.getInstance();
    final loginid = prefs.getString('loginid');
    final url = pre.getString('s_url');
//    final refreshtoken = ref.getString('ref_token');

    setState(() {
      loginId = loginid;
      URI = url;

      loginIdController.text = loginid;
      urlController.text = url;
    });

    return [url, loginid];
  }

  Future<void> _saveData([String refreshToken]) async {
    final prefs = await SharedPreferences.getInstance();
    final pre = await SharedPreferences.getInstance();
//    final ref = await SharedPreferences.getInstance();

    String currentid = loginIdController.text.toString();
    String currentUrl = urlController.text.toString();

//    if (refreshToken != null) {
//      await ref.setString('ref_token', refreshToken);
//    }

    if (loginIdController.text.isNotEmpty) {
      await prefs.setString('loginid', currentid);
      loginIdController.clear();
    }

    if (urlController.text.isNotEmpty) {
      await pre.setString('s_url', currentUrl);
      urlController.clear();

      // to recall init function when url is updated

//      getURI();
      login();
    }
  }

  initSocket(uri) async {
    print('hey from init');

    var identifier = 'working';
    SocketIO socket = await manager.createInstance(SocketOptions(
        //Socket IO server URI
        uri,
        nameSpace: "/reliefo",
        //Query params - can be used for authentication
        query: {
          "jwt": loginSession.jwt,
          "info": "new connection from adhara-socketio",
          "timestamp": DateTime.now().toString()
        },
        //Enable or disable platform channel logging
        enableLogging: true,
        transports: [
          Transports.WEB_SOCKET /*, Transports.POLLING*/
        ] //Enable required transport

        ));
    socket.onConnect((data) {
      pprint({"Status": "connected..."});
      setState(() {
        webSocketConnected = true;
      });
//      pprint(data);
//      sendMessage("DEFAULT");
      print("on Connected");
      print(data);
      socket.emit("fetchme", ["Hello world!"]);
      socket.emit("fetch_order_lists", ["arguments"]);
    });
    socket.onConnectError((data) {
      pprint(data);
      print('inside error fiun');
      disconnect('working');
    });
    socket.onConnectTimeout(pprint);
    socket.onError(pprint);
    socket.onReconnect((listener) {
//      print(listener);
      print('herllo rehere');
      disconnect('working');
//      refresh();
    });
    socket.onReconnecting((listener) {
      print('asdfsadfs');
    });

    socket.onReconnectError((listener) {
      print('asdfsadfs');
    });
    socket.onReconnectFailed((listener) {
      print('asdfsadfs');
    });
    socket.onDisconnect((data) {
      setState(() {
        webSocketConnected = false;
      });

      disconnect('working');
      print('object disconnnecgts');
//      while (refresh()) {
//        print('trying again');
//      }
    });
    socket.on("fetch", (data) => pprint(data));
    socket.on("new_orders", (data) => fetchNewOrders(data));
    socket.on("hand_shake", (data) => shakeHands(data));
    socket.on("order_lists", (data) => fetchInitialLists(data));
    socket.on("order_updates", (data) => fetchOrderUpdates(data));

    socket.connect();
    sockets[identifier] = socket;
  }

  shakeHands(data) {
    print("HEREREHRAFNDOKSVOD");
    if (data is Map) {
      data = json.encode(data);
    }

    sockets['working'].emit('hand_shook', ["arg"]);
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
//      print("object");
//      print(data);
      queueOrders.clear();
      cookingOrders.clear();
      completedOrders.clear();

      var decoded = jsonDecode(data);
//      print("object");

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

//      print(decoded);

      var selectedOrder;

      if (loginId != decoded['kitchen_app_id']) {
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
        "kitchen_app_id": loginId
      }
    ]);
    setState(() {
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
    print("Alert when not null");
    print(loginSession.headers['Authorization']);
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
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text('ID : $loginId'),
                  ),
                  Container(
                    child: Text('URL : $URI'),
                  ),
                ],
              ),
            ),
            Container(
              child: TextFormField(
                controller: loginIdController,
                decoration: InputDecoration(
                  labelText: "Enter Login id",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  //fillColor: Colors.green
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            Container(
              color: Colors.black26,
              child: FlatButton(
                child: Text('submit login id'),
                onPressed: () {
                  _saveData();
                  _getDataFromSaved();
                },
              ),
            ),
            Divider(),
            Container(
              child: TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: "Enter url",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  //fillColor: Colors.green
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            Container(
              color: Colors.black26,
              child: FlatButton(
                child: Text('submit url'),
                onPressed: () {
                  _saveData();
                  _getDataFromSaved();
                },
              ),
            ),

            Divider(),
            ///////////////////

            FlatButton(
              child: Text('login'),
              onPressed: () {
                login();
              },
            ),
            FlatButton(
              child: Text('get'),
              onPressed: () {
//                get_rest();
              },
            ),

            FlatButton(
              child: Text('Logout'),
              onPressed: () {
                setState(() {
                  webSocketConnected = false;
                });

                disconnect('working');
              },
            ),
          ],
        ),
      ),
    ));
  }
}
