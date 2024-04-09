import "package:infra_did_comm_dart/messages/commons/context.dart";

class DIDConnectedMessage {
  String id;
  String type = "DIDConnected";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  Context context;
  String status;

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

  factory DIDConnectedMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "DIDConnected") {
        throw Exception("Invalid type");
      }
      return DIDConnectedMessage(
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
        status: json["body"]["status"],
      );
    } catch (e) {
      rethrow;
    }
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
        "status": status,
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
