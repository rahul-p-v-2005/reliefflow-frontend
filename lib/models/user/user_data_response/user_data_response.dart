import 'user.dart';

class UserDataResponse {
  bool? success;
  User? data;

  UserDataResponse({this.success, this.data});

  @override
  String toString() => 'UserDataResponse(success: $success, data: $data)';

  factory UserDataResponse.fromJson(Map<String, dynamic> json) {
    return UserDataResponse(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : User.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data?.toJson(),
  };
}
