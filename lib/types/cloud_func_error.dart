import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';

class CloudFuncError {
  final String message;
  final String code;
  final String details;

  CloudFuncError({
    this.message = '',
    this.code = '',
    this.details = '',
  });

  factory CloudFuncError.empty() {
    return CloudFuncError(
      message: '',
      code: '',
      details: '',
    );
  }

  factory CloudFuncError.fromException(FirebaseFunctionsException exception) {
    if (exception == null) {
      return CloudFuncError.empty();
    }

    return CloudFuncError(
      code: exception.code ?? '',
      details: exception.details ?? '',
      message: exception.message ?? '',
    );
  }

  factory CloudFuncError.fromJSON(Map<dynamic, dynamic> data) {
    if (data == null) {
      return CloudFuncError.empty();
    }

    return CloudFuncError(
      code: data['code'] ?? '',
      details: data['details'] ?? '',
      message: data['message'] ?? '',
    );
  }

  factory CloudFuncError.fromMessage(String message) {
    if (message == null) {
      return CloudFuncError.empty();
    }

    return CloudFuncError(
      code: '',
      details: '',
      message: message,
    );
  }

  factory CloudFuncError.fromPlatformException(PlatformException exception) {
    if (exception == null) {
      return CloudFuncError.empty();
    }

    return CloudFuncError(
      code: exception.code ?? '',
      details: exception.details ?? '',
      message: exception.message ?? '',
    );
  }
}
