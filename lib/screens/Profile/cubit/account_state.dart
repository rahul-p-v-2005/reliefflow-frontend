part of 'account_cubit.dart';

@immutable
sealed class AccountState {}

final class AccountInitial extends AccountState {}

final class AccountLoading extends AccountState {}

final class AccountLoaded extends AccountState {
  final User user;

  AccountLoaded({
    required this.user,
  });
}

final class AccountError extends AccountState {
  final String message;
  final int statusCode;

  AccountError({required this.message, this.statusCode = 0});
}
