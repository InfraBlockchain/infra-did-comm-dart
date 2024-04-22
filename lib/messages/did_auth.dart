import "package:infra_did_comm_dart/messages/commons/context.dart";

/// Represents a DIDAuth message.
class DIDAuthMessage {
  String id;
  String type = "DIDAuth";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  Context context;
  String? socketId;
  String peerSocketId;

  /// Constructs a [DIDAuthMessage] instance.
  DIDAuthMessage({
    required this.id,
    required this.from,
    required this.to,
    this.createdTime,
    this.expiresTime,
    required this.context,
    this.socketId,
    required this.peerSocketId,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    context = context;
    socketId = socketId;
    peerSocketId = peerSocketId;
  }

  /// Constructs a [DIDAuthMessage] instance from a JSON map.
  factory DIDAuthMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "DIDAuth") {
        throw Exception("Invalid type");
      }
      return DIDAuthMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        createdTime:
            json.containsKey("created_time") ? json["created_time"] : 0,
        expiresTime:
            json.containsKey("expires_time") ? json["expires_time"] : 0,
        context: json["body"].containsKey("context")
            ? Context.fromJson(json["body"]["context"])
            : Context.fromCompactJson(json["body"]["c"]),
        socketId: json["body"].containsKey("socketId")
            ? json["body"]["socketId"]
            : null,
        peerSocketId: json["body"]["peerSocketId"],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [DIDAuthMessage] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["id"] = id;
      data["type"] = type;
      data["from"] = from;
      data["to"] = to;
      if (createdTime != null) data["created_time"] = createdTime;
      if (expiresTime != null) data["expires_time"] = expiresTime;
      data["body"] = {
        "context": context.toJson(),
        "peerSocketId": peerSocketId,
      };
      if (socketId != null) {
        data["body"]["socketId"] = socketId;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
