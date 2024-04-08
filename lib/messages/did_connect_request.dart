import "package:infra_did_comm_dart/messages/commons/context.dart";
import "package:infra_did_comm_dart/messages/commons/initiator.dart";
import "package:infra_did_comm_dart/types/types.dart";
import "package:infra_did_comm_dart/utils/utils.dart";

class DIDConnectRequestMessage {
  String type = "DIDConnectReq";
  String from;
  int? createdTime;
  int? expiresTime;
  Context context;
  Initiator initiator;

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

  factory DIDConnectRequestMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "DIDConnectReq") {
        throw Exception("Invalid type");
      }
      return DIDConnectRequestMessage(
        from: json["from"],
        createdTime:
            json.containsKey("created_time") ? json["created_time"] : 0,
        expiresTime:
            json.containsKey("expires_time") ? json["expires_time"] : 0,
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

  static DIDConnectRequestMessage decode(String encoded) {
    try {
      Map<String, dynamic> data = inflateAndDecode(encoded);
      return DIDConnectRequestMessage.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["type"] = type;
      data["from"] = from;
      data["created_time"] = createdTime;
      data["expires_time"] = expiresTime;
      data["body"] = {
        "initiator": initiator.toJson(),
        "context": context.toJson(),
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toCompactJson() {
    try {
      final Map<String, dynamic> data = {};
      data["type"] = type;
      data["from"] = from;
      data["created_time"] = createdTime;
      data["expires_time"] = expiresTime;
      data["body"] = {
        "i": initiator.toCompactJson(),
        "c": context.toCompactJson(),
      };
      return data;
    } catch (e) {
      rethrow;
    }
  }

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
