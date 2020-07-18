class TableOrder {
  String oId;
  String table;
  String status = 'queued';

  List<Order> orders;
  DateTime timeStamp;

  TableOrder({this.oId, this.table, this.orders, this.timeStamp, this.status});

  TableOrder.fromJson(Map<String, dynamic> json, String kitchenId) {
    oId = json['_id']['\$oid'];

    table = json['table'];

    orders = new List<Order>();
    json['orders'].forEach((v) {
      orders.add(new Order.fromJson(v, kitchenId));
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

  Order.fromJson(Map<String, dynamic> json, String kitchenId) {
    placedBy = json['placed_by']['\$oid'];
    oId = json['_id']['\$oid'];

    foodList = new List<FoodItem>();
    Map<String, dynamic> tempFood = {};
    json['food_list'].forEach((v) {
      if (v["kitchen"] == kitchenId) {
        tempFood = v;
      }

      if (tempFood != null && tempFood.isNotEmpty) {
        foodList.add(FoodItem.fromJson(tempFood));
      }
    });
    print("orders are coming here");
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
  FoodOption foodOption;
  FoodItem({
    this.description,
    this.name,
    this.price,
    this.foodId,
    this.quantity,
    this.status,
    this.instructions,
    this.foodOption,
  });

  FoodItem.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    name = json['name'];
    price = json['price'];
    foodId = json['food_id'];
    quantity = json['quantity'];
    instructions = json['instructions'];

    if (json['food_options'] != null) {
      foodOption = new FoodOption.fromJson(json['food_options']);
    }
  }
}

class FoodOption {
  List<Map<String, dynamic>> options;
  List<String> choices;

  FoodOption({
    this.options,
    this.choices,
  });

  FoodOption.fromJson(Map<String, dynamic> json) {
//    print("while adding food iption");
//    print(json['options']);
    if (json['options'] != null) {
      options = new List<Map<String, dynamic>>();
      json['options'].forEach((option) {
//        print("here");
//        print(option["option_name"]);
//        print(option["option_price"]);
        options.add(option);

//        print("added");
      });
    }

    if (json['choices'] != null) {
      choices = new List<String>();
      json['choices'].forEach((v) {
        choices.add(v);
      });
    }
  }
}
