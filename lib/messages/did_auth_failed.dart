import "package:infra_did_comm_dart/messages/commons/context.dart";

/// Represents a DID Auth Failed message.
class DIDAuthFailedMessage {
  String id;
  String type = "DIDAuthFailed";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  Context context;
  String reason;

  /// Constructs a [DIDAuthFailedMessage] instance.
  DIDAuthFailedMessage({
    required this.id,
    required this.from,
    required this.to,
    this.createdTime,
    this.expiresTime,
    required this.context,
    required this.reason,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    context = context;
    reason = reason;
  }

  /// Constructs a [DIDAuthFailedMessage] instance from a JSON object.
  factory DIDAuthFailedMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "DIDAuthFailed") {
        throw Exception("Invalid type");
      }
      return DIDAuthFailedMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        context: json["body"].containsKey("context")
            ? Context.fromJson(json["body"]["context"])
            : Context.fromCompactJson(json["body"]["c"]),
        reason: json["body"]["reason"],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [DIDAuthFailedMessage] instance to a JSON object.
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
        "reason": reason,
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
