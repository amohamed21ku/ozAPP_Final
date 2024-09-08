class Customer {
  String name;
  String company;
  String initial;
  String cid;
  Map<String, dynamic> items;
  Map<String, dynamic> goods;

  Customer({
    required this.name,
    required this.company,
    required this.initial,
    required this.cid,
    required this.items,
    required this.goods,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'company': company,
      'initial': initial,
      'cid': cid,
      'items': items,
      'goods': goods,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      company: json['company'],
      initial: json['initial'],
      cid: json['cid'],
      items: json['items'],
      goods: json['goods'],
    );
  }
}
