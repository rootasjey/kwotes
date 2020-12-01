class CloudFuncError {
  final String message;
  final String code;
  final String details;

  CloudFuncError({
    this.message = '',
    this.code = '',
    this.details = '',
  });

  factory CloudFuncError.fromJSON(Map<dynamic, dynamic> data) {
    return CloudFuncError(
      message: data['message'],
      code: data['code'],
      details: data['details'],
    );
  }
}
