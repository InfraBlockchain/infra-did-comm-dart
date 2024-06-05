import "package:infra_did_comm_dart/messages/commons/context.dart";

/// Represents a DID Connected message.
class DIDConnectedMessage {
  String id;
  String type = "DIDConnected";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  Context context;
  String status;

  /// Constructs a [DIDConnectedMessage] instance.
  DIDConnectedMessage({
    required this.id,
    required this.from,
    required this.to,
    this.createdTime,
    this.expiresTime,
    required this.context,
    required this.status,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    context = context;
    status = status;
  }

  /// Constructs a [DIDConnectedMessage] instance from a JSON map.
  factory DIDConnectedMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "DIDConnected") {
        throw Exception("Invalid type");
      }
      return DIDConnectedMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        context: json["body"].containsKey("context")
            ? Context.fromJson(json["body"]["context"])
            : Context.fromCompactJson(json["body"]["c"]),
        status: json["body"]["status"],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [DIDConnectedMessage] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["id"] = id;
      data["type"] = type;
      data["from"] = from;
      data["to"] = to;
      if (createdTime != null) data["createdTime"] = createdTime;
      if (expiresTime != null) data["expiresTime"] = expiresTime;
      data["body"] = {
        "context": context.toJson(),
        "status": status,
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
