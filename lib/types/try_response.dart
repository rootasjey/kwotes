import 'error_reason.dart';

class TryResponse {
  bool hasErrors;
  ErrorReason reason;

  TryResponse({this.hasErrors, this.reason});
}
