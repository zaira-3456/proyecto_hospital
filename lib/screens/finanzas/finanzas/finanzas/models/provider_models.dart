class Provider {
  final String name;
  final String phone;
  final String email;
  final String service;
  final String status;

  Provider({
    required this.name,
    required this.phone,
    required this.email,
    required this.service,
    required this.status,
  });
}

class PurchaseOrder {
  final String id;
  final String providerName;
  final String type;
  final String area;
  final double budget;
  final String status;

  PurchaseOrder({
    required this.id,
    required this.providerName,
    required this.type,
    required this.area,
    required this.budget,
    required this.status,
  });
}
