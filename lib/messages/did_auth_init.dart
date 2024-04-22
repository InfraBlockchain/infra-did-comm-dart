import "package:infra_did_comm_dart/messages/commons/context.dart";

/// Represents a DID Auth Init message.
class DIDAuthInitMessage {
  String id;
  String type = "DIDAuthInit";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  Context context;
  String socketId;
  String peerSocketId;

  /// Constructs a new [DIDAuthInitMessage] instance.
  ///
  /// The [id], [from], [to], [context], [socketId], and [peerSocketId] parameters are required.
  /// The [createdTime] and [expiresTime] parameters are optional.
  DIDAuthInitMessage({
    required this.id,
    required this.from,
    required this.to,
    this.createdTime,
    this.expiresTime,
    required this.context,
    required this.socketId,
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

  /// Converts the [DIDAuthInitMessage] instance to a JSON object.
  ///
  /// Returns a map representing the JSON object.
  /// Throws an exception if an error occurs during the conversion.
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
        "socketId": socketId,
        "peerSocketId": peerSocketId,
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
