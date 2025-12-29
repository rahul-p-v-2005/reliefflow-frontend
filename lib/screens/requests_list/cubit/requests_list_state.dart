part of 'requests_list_cubit.dart';

@immutable
sealed class RequestsListState {}

final class RequestsListInitial extends RequestsListState {}

final class RequestsListLoading extends RequestsListState {}

final class RequestsListLoaded extends RequestsListState {
  final List<DonationRequest> donationRequests;
  final List<DonationRequest> allDonationRequests;
  final List<AidRequest> aidRequests;
  final List<AidRequest> allAidRequests;

  RequestsListLoaded({
    required this.donationRequests,
    required this.allDonationRequests,
    required this.aidRequests,
    required this.allAidRequests,
  });
}

final class RequestsListError extends RequestsListState {
  final String message;
  final int statusCode;

  RequestsListError({required this.message, this.statusCode = 0});
}
