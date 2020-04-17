class TableOrder {
  String oId;
  String table;
  String status = 'queued';

  List<Order> orders;
  DateTime timeStamp;

  TableOrder({this.oId, this.table, this.orders, this.timeStamp, this.status});

  TableOrder.fromJson(Map<String, dynamic> json) {
    oId = json['_id']['\$oid'];

    RegExp regExp = new RegExp("[0-9]+");

    table = regExp.firstMatch(json['table']).group(0);

    orders = new List<Order>();
    json['orders'].forEach((v) {
      orders.add(new Order.fromJson(v));
    });

    timeStamp = DateTime.parse(json['timestamp']);
  }
  TableOrder.fromJsonNew(Map<String, dynamic> json) {
    oId = json['oId'];

    table = json['table'];
    status = json['status'];
    timeStamp = json['timestamp'];
  }
  addFirstOrder(Order order) {
    this.orders = new List<Order>();
    this.orders.add(order);
  }

  addOrder(Order order) {
    this.orders.add(order);
  }

  cleanOrders(String order_id) {
    var delete = false;
    print(this.orders.length);
    this.orders.forEach((order) {
      if (order.oId == order_id) {
        if (order.foodList.length == 0) delete = true;
      }
    });
    if (delete) this.orders.removeWhere((order) => order.oId == order_id);
    print(this.orders.length);
  }

  bool selfDestruct() {
    return this.orders.isEmpty;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['oId'] = this.oId;
    data['table'] = this.table;
    data['status'] = this.status;
    data['timestamp'] = this.timeStamp;
    return data;
  }
}

class Order {
  String oId;
  String placedBy;

  List<FoodItem> foodList;
  String status = 'queued';

  Order({this.oId, this.placedBy, this.foodList, this.status});

  Order.fromJson(Map<String, dynamic> json) {
    placedBy = json['placed_by']['\$oid'];
    oId = json['_id']['\$oid'];

    foodList = new List<FoodItem>();
    json['food_list'].forEach((v) {
      foodList.add(FoodItem.fromJson(v));
    });
  }

  Order.fromJsonNew(Map<String, dynamic> json) {
    placedBy = json['placed_by'];
    oId = json['oId'];
    status = json['status'];
  }
  addFirstFood(FoodItem food) {
    this.foodList = new List<FoodItem>();
    this.foodList.add(food);
  }

  addFood(FoodItem food) {
    this.foodList.add(food);
  }

  removeFoodItem(String food_id) {
    this.foodList.removeWhere((food) => food.foodId == food_id);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['oId'] = this.oId;
    data['placed_by'] = this.placedBy;
    data['status'] = this.status;
    return data;
  }
}

class FoodItem {
  String description;
  String name;
  String price;
  String foodId;
  String instructions;
  String status = 'queued';
  int quantity;

  FoodItem(
      {this.description,
      this.name,
      this.price,
      this.foodId,
      this.quantity,
      this.status,
      this.instructions});

  FoodItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    name = json['name'];
    price = json['price'];
    foodId = json['food_id'];
    quantity = json['quantity'];
    instructions = json['instructions'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    data['name'] = this.name;
    data['price'] = this.price;
    data['food_id'] = this.foodId;
    data['quantity'] = this.quantity;
    data['instructions'] = this.instructions;
    return data;
  }
}
