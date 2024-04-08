import "package:infra_did_comm_dart/messages/commons/context.dart";

class DIDAuthFailedMessage {
  String id;
  String type = "DIDAuthFailed";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  Context context;
  String reason;

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
        "reason": reason,
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
