import 'package:cloud_functions/cloud_functions.dart';
import 'package:fig_style/types/cloud_func_error.dart';
import 'package:fig_style/types/partial_user.dart';

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

  factory CreateAccountResp.empty() {
    return CreateAccountResp(
      success: false,
      user: PartialUser.empty(),
      error: CloudFuncError.empty(),
    );
  }

  factory CreateAccountResp.fromException(
      FirebaseFunctionsException exception) {
    if (exception == null) {
      return CreateAccountResp.empty();
    }

    return CreateAccountResp(
      error: CloudFuncError.fromException(exception),
      success: false,
      user: PartialUser.empty(),
    );
  }

  factory CreateAccountResp.fromJSON(Map<dynamic, dynamic> data) {
    if (data == null) {
      return CreateAccountResp.empty();
    }

    return CreateAccountResp(
      error: CloudFuncError.fromJSON(data['error']),
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
    );
  }

  factory CreateAccountResp.fromMessage(String message) {
    if (message == null) {
      return CreateAccountResp.empty();
    }

    return CreateAccountResp(
      error: CloudFuncError.fromMessage(message),
      success: false,
      user: PartialUser.empty(),
    );
  }
}
