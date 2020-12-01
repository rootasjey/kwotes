import 'package:figstyle/types/cloud_func_error.dart';
import 'package:figstyle/types/partial_user.dart';

class UpdateEmailResp {
  bool success;
  final CloudFuncError error;
  final PartialUser user;

  UpdateEmailResp({
    this.success = true,
    this.error,
    this.user,
  });

  factory UpdateEmailResp.fromJSON(Map<dynamic, dynamic> data) {
    return UpdateEmailResp(
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
