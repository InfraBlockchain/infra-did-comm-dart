class SubmitVPLaterMessage {
  String id;
  String type = "VPSubmitLater";
  String from;
  List<String> to;
  List<String>? ack;
  int? createdTime;
  int? expiresTime;

  SubmitVPLaterMessage({
    required this.id,
    required this.from,
    required this.to,
    this.ack,
    this.createdTime,
    this.expiresTime,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    ack = ack;
  }

  factory SubmitVPLaterMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "VPSubmitLater") {
        throw Exception("Invalid type");
      }
      return SubmitVPLaterMessage(
        id: json["id"],
        from: json["from"],
        to: (json["to"] as List<dynamic>)
            .map<String>((e) => e.toString())
            .toList(),
        ack: json.containsKey("ack") ? List<String>.from(json["ack"]) : [],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [SubmitVPLaterMessage] instance to a JSON map.
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
      data["body"] = {};
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
