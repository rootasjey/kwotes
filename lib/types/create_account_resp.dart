import 'package:figstyle/types/cloud_func_error.dart';
import 'package:figstyle/types/partial_user.dart';

class CreateAccountResp {
  bool success;
  final String message;
  final CloudFuncError error;
  final PartialUser user;

  CreateAccountResp({
    this.success = true,
    this.message = '',
    this.error,
    this.user,
  });

  factory CreateAccountResp.fromJSON(Map<dynamic, dynamic> data) {
    return CreateAccountResp(
      success: data['success'] ?? true,
      user: data['user'] != null
          ? PartialUser.fromJSON(data['user'])
          : PartialUser(),
      error: data['error'] != null
          ? CloudFuncError.fromJSON(data['error'])
          : CloudFuncError(),
    );
  }
}
