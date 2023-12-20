class MessageModel {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sendTime;
  final MessageType messageType;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sendTime,
    required this.messageType,
  });

  factory MessageModel.fromJson(Object? json) {
    if (json == null) {
      // Handle null input if necessary
      throw ArgumentError('json cannot be null');
    }

    if (json is Map<String, dynamic>) {
      return MessageModel(
        senderId: json["senderId"],
        receiverId: json["receiverId"],
        content: json["content"],
        sendTime: json["sendTime"]?.toDate(),
        messageType: MessageType.fromJson(json["messageType"]),
      );
    } else {
      throw ArgumentError('json must be a Map<String, dynamic>');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sendTime': sendTime,
      'messageType': messageType.toJson(),
    };
  }
}

enum MessageType {
  text,
  image;

  String toJson() => name;

  factory MessageType.fromJson(String json) => values.byName(json);
}
