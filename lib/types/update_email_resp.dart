import 'package:cloud_functions/cloud_functions.dart';
import 'package:fig_style/types/cloud_func_error.dart';
import 'package:fig_style/types/partial_user.dart';
import 'package:flutter/services.dart';

class UpdateEmailResp {
  bool success;
  final CloudFuncError error;
  final PartialUser user;

  UpdateEmailResp({
    this.success = true,
    this.error,
    this.user,
  });

  factory UpdateEmailResp.empty() {
    return UpdateEmailResp(
      success: true,
      user: PartialUser.empty(),
      error: CloudFuncError.empty(),
    );
  }

  factory UpdateEmailResp.fromException(FirebaseFunctionsException exception) {
    if (exception == null) {
      return UpdateEmailResp.empty();
    }

    return UpdateEmailResp(
      success: false,
      user: PartialUser.empty(),
      error: CloudFuncError.fromException(exception),
    );
  }

  factory UpdateEmailResp.fromMessage(String message) {
    if (message == null) {
      return UpdateEmailResp.empty();
    }

    return UpdateEmailResp(
      success: false,
      user: PartialUser.empty(),
      error: CloudFuncError.fromMessage(message),
    );
  }

  factory UpdateEmailResp.fromJSON(Map<dynamic, dynamic> data) {
    if (data == null) {
      return UpdateEmailResp.empty();
    }

    return UpdateEmailResp(
      success: data['success'] ?? true,
      user: PartialUser.fromJSON(data['user']),
      error: CloudFuncError.fromJSON(data['error']),
    );
  }

  factory UpdateEmailResp.fromPlatformException(PlatformException exception) {
    if (exception == null) {
      return UpdateEmailResp.empty();
    }

    return UpdateEmailResp(
      success: false,
      user: PartialUser.empty(),
      error: CloudFuncError.fromPlatformException(exception),
    );
  }
}
