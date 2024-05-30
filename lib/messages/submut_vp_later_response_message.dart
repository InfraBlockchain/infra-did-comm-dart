class SubmitVPLaterResponseMessage {
  String id;
  String type = "VPSubmitLaterRes";
  String from;
  List<String> to;
  List<String>? ack;
  int? createdTime;
  int? expiresTime;
  String callbackUrl;

  SubmitVPLaterResponseMessage({
    required this.id,
    required this.from,
    required this.to,
    this.ack,
    this.createdTime,
    this.expiresTime,
    required this.callbackUrl,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    ack = ack;
    callbackUrl = callbackUrl;
  }

  factory SubmitVPLaterResponseMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "SubmitVPLaterRes") {
        throw Exception("Invalid type");
      }
      return SubmitVPLaterResponseMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        ack: json.containsKey("ack") ? List<String>.from(json["ack"]) : [],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        callbackUrl: json["body"]["callback_url"],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [SubmitVPLaterResponseMessage] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["id"] = id;
      data["type"] = type;
      data["from"] = from;
      data["to"] = to;
      data["ack"] = ack;
      data["createdTime"] = createdTime;
      data["expiresTime"] = expiresTime;
      data["body"] = {"callbackUrl": callbackUrl};
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
