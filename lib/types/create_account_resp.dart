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

  factory CreateAccountResp.fromJSON(Map<String, dynamic> data) {
    return CreateAccountResp(
      success: data['success'],
      user: data['user'],
      error: CloudFuncError.fromJSON(data['error']),
    );
  }
}
