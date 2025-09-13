class BillItem {
  String name;
  double price;
  List<String> sharedWith;

  BillItem({
    required this.name,
    required this.price,
    required this.sharedWith,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'sharedWith': sharedWith,
    };
  }

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      name: json['name'],
      price: json['price'].toDouble(),
      sharedWith: List<String>.from(json['sharedWith']),
    );
  }
}