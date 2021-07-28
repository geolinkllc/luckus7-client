
class MessageResponse{
  String message;

  MessageResponse(this.message);

  factory MessageResponse.fromMap(Map<String, dynamic> map) {
    return new MessageResponse(
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