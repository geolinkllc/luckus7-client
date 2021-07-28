class AsyncMessage {
  String message;

  AsyncMessage(this.message);

  factory AsyncMessage.fromMap(Map<String, dynamic> map) {
    return new AsyncMessage(
      map['message'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'message': this.message,
    } as Map<String, dynamic>;
  }
}
