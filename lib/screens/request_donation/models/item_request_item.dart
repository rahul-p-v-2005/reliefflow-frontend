// import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';

import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item_category.dart';

class ItemRequestItem {
  final ItemCategory category;
  final String description;
  final String quantity;
  final String unit;

  ItemRequestItem({
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
  });
}
