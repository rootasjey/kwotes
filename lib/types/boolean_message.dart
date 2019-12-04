class BooleanMessage {
  bool boolean;
  String message;

  BooleanMessage({this.boolean, this.message});

  factory BooleanMessage.fromJSON(Map<String, dynamic> json) {
    return BooleanMessage(
      boolean: json['bool'],
      message: json['message'],
    );
  }
}
