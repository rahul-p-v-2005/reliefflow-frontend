import 'dart:io';
import 'package:equatable/equatable.dart';

enum DonationSubmitStatus { initial, loading, success, error }

class CashDonationState extends Equatable {
  final String title;
  final String description;
  final String amount;
  final String upiId;
  final DateTime? deadline;
  final List<File> images;
  final DonationSubmitStatus status;
  final String? errorMessage;

  const CashDonationState({
    this.title = '',
    this.description = '',
    this.amount = '',
    this.upiId = '',
    this.deadline,
    this.images = const [],
    this.status = DonationSubmitStatus.initial,
    this.errorMessage,
  });

  CashDonationState copyWith({
    String? title,
    String? description,
    String? amount,
    String? upiId,
    DateTime? deadline,
    bool clearDeadline = false,
    List<File>? images,
    DonationSubmitStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CashDonationState(
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      upiId: upiId ?? this.upiId,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      images: images ?? this.images,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get isValid =>
      title.isNotEmpty &&
      description.isNotEmpty &&
      amount.isNotEmpty &&
      upiId.isNotEmpty &&
      double.tryParse(amount) != null;

  @override
  List<Object?> get props => [
    title,
    description,
    amount,
    upiId,
    deadline,
    images,
    status,
    errorMessage,
  ];
}
