import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:reliefflow_frontend_public_app/models/location_search_response/feature.dart';
import 'package:reliefflow_frontend_public_app/screens/request_donation/models/item_request_item.dart';

enum DonationSubmitStatus { initial, loading, success, error }

class ItemsDonationState extends Equatable {
  final String title;
  final String description;
  final List<ItemRequestItem> items;
  final Feature? location;
  final DateTime? deadline;
  final List<File> images;
  final DonationSubmitStatus status;
  final String? errorMessage;

  const ItemsDonationState({
    this.title = '',
    this.description = '',
    this.items = const [],
    this.location,
    this.deadline,
    this.images = const [],
    this.status = DonationSubmitStatus.initial,
    this.errorMessage,
  });

  ItemsDonationState copyWith({
    String? title,
    String? description,
    List<ItemRequestItem>? items,
    Feature? location,
    bool clearLocation = false,
    DateTime? deadline,
    bool clearDeadline = false,
    List<File>? images,
    DonationSubmitStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ItemsDonationState(
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      location: clearLocation ? null : (location ?? this.location),
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      images: images ?? this.images,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isValid =>
      title.isNotEmpty && description.isNotEmpty && items.isNotEmpty;

  @override
  List<Object?> get props => [
    title,
    description,
    items,
    location,
    deadline,
    images,
    status,
    errorMessage,
  ];
}
