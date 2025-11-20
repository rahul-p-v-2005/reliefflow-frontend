import 'package:flutter/cupertino.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';

class AddedItems extends ValueNotifier {
  AddedItems(super.value);

  final List<ItemRequestItem> _addedItems = [];

  List<ItemRequestItem> get items => _addedItems;

  void add(ItemRequestItem item) {
    _addedItems.add(item);
    notifyListeners();
  }
}

AddedItems addedItems = AddedItems([]);
