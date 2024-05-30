class SubmitVPMessage {
  String id;
  String type = "VPSubmit";
  String from;
  List<String> to;
  List<String>? ack;
  int? createdTime;
  int? expiresTime;
  String vp;

  SubmitVPMessage({
    required this.id,
    required this.from,
    required this.to,
    this.ack,
    this.createdTime,
    this.expiresTime,
    required this.vp,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    ack = ack;
    vp = vp;
  }

  factory SubmitVPMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "SubmitVP") {
        throw Exception("Invalid type");
      }
      return SubmitVPMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        ack: json.containsKey("ack") ? List<String>.from(json["ack"]) : [],
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        vp: json["body"]["vp"],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [SubmitVPMessage] instance to a JSON map.
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
      data["body"] = {"vp": vp};
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
