import "package:infra_did_comm_dart/commons/context.dart";

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
