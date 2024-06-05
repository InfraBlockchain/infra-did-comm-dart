import "package:infra_did_comm_dart/messages/commons/context.dart";
import "package:infra_did_comm_dart/messages/commons/initiator.dart";
import "package:infra_did_comm_dart/types/types.dart";
import "package:infra_did_comm_dart/utils/encode.dart";

/// Represents a DID Connect Request message.
class DIDConnectRequestMessage {
  String type = "DIDConnectReq";
  String from;
  int? createdTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  int? expiresTime = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 30000;
  Context context;
  Initiator initiator;

  /// Constructs a [DIDConnectRequestMessage] instance.
  ///
  /// The [from] parameter specifies the sender of the message.
  /// The [createdTime] parameter specifies the time when the message was created.
  /// The [expiresTime] parameter specifies the time when the message expires.
  /// The [context] parameter specifies the context of the message.
  /// The [initiator] parameter specifies the initiator of the message.
  DIDConnectRequestMessage({
    required this.from,
    this.createdTime,
    this.expiresTime,
    required this.context,
    required this.initiator,
  }) {
    from = from;
    createdTime = createdTime;
    expiresTime = expiresTime;
    context = context;
    initiator = initiator;
  }

  /// Constructs a [DIDConnectRequestMessage] instance from a JSON map.
  ///
  /// The [json] parameter specifies the JSON map to construct the message from.
  factory DIDConnectRequestMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "DIDConnectReq") {
        throw Exception("Invalid type");
      }
      return DIDConnectRequestMessage(
        from: json["from"],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        context: json["body"].containsKey("context")
            ? Context.fromJson(json["body"]["context"])
            : Context.fromCompactJson(json["body"]["c"]),
        initiator: json["body"].containsKey("initiator")
            ? Initiator.fromJson(json["body"]["initiator"])
            : Initiator.fromCompactJson(json["body"]["i"]),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Encodes the message to a string representation.
  ///
  /// The [compressLevel] parameter specifies the compression level to use.
  String encode(CompressionLevel compressLevel) {
    try {
      Map<String, dynamic> data = {};
      if (compressLevel == CompressionLevel.json) {
        data = toJson();
      }
      if (compressLevel == CompressionLevel.compactJSON) {
        data = toCompactJson();
      }
      if (compressLevel == CompressionLevel.minimalCompactJSON) {
        data = toMinimalCompactJson();
      }

      return deflateAndEncode(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Decodes the message from an encoded string.
  ///
  /// The [encoded] parameter specifies the encoded string to decode.
  static DIDConnectRequestMessage decode(String encoded) {
    try {
      Map<String, dynamic> data = inflateAndDecode(encoded);
      return DIDConnectRequestMessage.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the message to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["type"] = type;
      data["from"] = from;
      data["createdTime"] = createdTime;
      data["expiresTime"] = expiresTime;
      data["body"] = {
        "initiator": initiator.toJson(),
        "context": context.toJson(),
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the message to a compact JSON map.
  Map<String, dynamic> toCompactJson() {
    try {
      final Map<String, dynamic> data = {};
      data["type"] = type;
      data["from"] = from;
      data["createdTime"] = createdTime;
      data["expiresTime"] = expiresTime;
      data["body"] = {
        "i": initiator.toCompactJson(),
        "c": context.toCompactJson(),
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the message to a minimal compact JSON map.
  Map<String, dynamic> toMinimalCompactJson() {
    try {
      final Map<String, dynamic> data = {};
      data["from"] = from;
      data["body"] = {
        "i": initiator.toMinimalCompactJson(),
        "c": context.toMinimalCompactJson(),
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
