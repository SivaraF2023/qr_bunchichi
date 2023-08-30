import 'dart:convert';

List<Order> orderFromJson(String str) => List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

String orderToJson(List<Order> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Order {
  Order({
    required this.orderId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.guests,
    required this.order,
  });

  final String orderId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<Guests> guests;
  final OrderClass order;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    orderId: json["orderId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    guests: List<Guests>.from(json["guests"].map((x) => Guests.fromJson(x))),
    order: OrderClass.fromJson(json["order"]),
  );

  Map<String, dynamic> toJson() => {
    "orderId": orderId,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "guests": List<dynamic>.from(guests.map((x) => x.toJson())),
    "order": order.toJson(),
  };
}

class OrderClass {
  OrderClass({
    required this.title,
    required this.date,
    required this.orderStatus,
    required this.qty,
    required this.totalPrice,
  });

  final String title;
  final String date;
  final String orderStatus;
  final int qty;
  final String totalPrice;

  factory OrderClass.fromJson(Map<String, dynamic> json) => OrderClass(
    title: json["title"],
    date: json["date"],
    orderStatus: json["orderStatus"],
    qty: json["qty"],
    totalPrice: json["totalPrice"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "date": date,
    "orderStatus": orderStatus,
    "qty": qty,
    "totalPrice": totalPrice,
  };
}

class Guests {
  Guests({
    required this.firstName,
    required this.phone,
    required this.age,
    required this.gender,
    required this.socialMedia,
  });

  final String firstName;
  final String phone;
  final String age;
  final String gender;
  final String socialMedia;

  factory Guests.fromJson(Map<String, dynamic> json) => Guests(
    firstName: json["firstName"],
    phone: json["phone"],
    age: json["age"],
    gender: json["gender"],
    socialMedia: json["socialMedia"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "phone": phone,
    "age": age,
    "gender": gender,
    "socialMedia": socialMedia,
  };
}
