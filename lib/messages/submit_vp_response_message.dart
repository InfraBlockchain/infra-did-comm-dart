class SubmitVPResponseMessage {
  String id;
  String type = "VPSubmitRes";
  String from;
  List<String> to;
  List<String>? ack;
  int? createdTime;
  int? expiresTime;
  String status;

  SubmitVPResponseMessage({
    required this.id,
    required this.from,
    required this.to,
    this.ack,
    this.createdTime,
    this.expiresTime,
    required this.status,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    ack = ack;
    status = status;
  }

  factory SubmitVPResponseMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "SubmitVPRes") {
        throw Exception("Invalid type");
      }
      return SubmitVPResponseMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        ack: json.containsKey("ack") ? List<String>.from(json["ack"]) : [],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        status: json["status"],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [SubmitVPResponseMessage] instance to a JSON map.
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
      data["body"] = {"status": status};
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
