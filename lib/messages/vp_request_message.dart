class VPRequestMessage {
  String id;
  String type = "VPReq";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  List<RequestVC> vcRequirements;
  String challenge;

  VPRequestMessage({
    required this.id,
    required this.from,
    required this.to,
    this.createdTime,
    this.expiresTime,
    required this.vcRequirements,
    required this.challenge,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    vcRequirements = vcRequirements;
    challenge = challenge;
  }

  factory VPRequestMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "VPReq") {
        throw Exception("Invalid type");
      }
      List<RequestVC> vcRequirements =
          (json["body"]["vcRequirements"] as List<dynamic>)
              .map<RequestVC>((vc) => RequestVC.fromJson(vc))
              .toList();

      return VPRequestMessage(
        id: json["id"],
        from: json["from"],
        to: (json["to"] as List<dynamic>)
            .map<String>((e) => e.toString())
            .toList(),
        createdTime: json.containsKey("createdTime") ? json["createdTime"] : 0,
        expiresTime: json.containsKey("expiresTime") ? json["expiresTime"] : 0,
        vcRequirements: vcRequirements,
        challenge: json["body"]["challenge"],
      );
    } catch (e) {
      print("Error in VPRequestMessage.fromJson: $e");
      rethrow;
    }
  }

  /// Converts the [VPRequestMessage] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["id"] = id;
      data["type"] = type;
      data["from"] = from;
      data["to"] = to;
      data["createdTime"] = createdTime;
      data["expiresTime"] = expiresTime;
      data["body"] = {
        "vcRequirements": vcRequirements.map((vc) => vc.toJson()).toList(),
        "challenge": challenge
      };
      return data;
    } catch (e) {
      print("Error in VPRequestMessage.toJson: $e");
      rethrow;
    }
  }
}

class RequestVC {
  String vcType;
  RequestVCQuery? query;

  RequestVC({
    required this.vcType,
    this.query,
  });

  factory RequestVC.fromJson(Map<String, dynamic> json) {
    try {
      return RequestVC(
        vcType: json["vcType"],
        query: json.containsKey("query")
            ? RequestVCQuery.fromJson(json["query"])
            : null,
      );
    } catch (e) {
      print("Error in RequestVC.fromJson: $e");
      rethrow;
    }
  }

  /// Converts the [RequestVC] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["vcType"] = vcType;
      if (query != null) {
        data["query"] = query!.toJson();
      }
      return data;
    } catch (e) {
      print("Error in RequestVC.toJson: $e");
      rethrow;
    }
  }
}

class RequestVCQuery {
  List<String>? selectedClaims;
  List<String>? filterConditions;

  RequestVCQuery({
    this.selectedClaims,
    this.filterConditions,
  });

  factory RequestVCQuery.fromJson(Map<String, dynamic> json) {
    try {
      return RequestVCQuery(
        selectedClaims:
            json.containsKey("selectedClaims") ? json["selectedClaims"] : null,
        filterConditions: json.containsKey("filterConditions")
            ? json["filterConditions"]
            : null,
      );
    } catch (e) {
      print("Error in RequestVCQuery.fromJson: $e");
      rethrow;
    }
  }

  /// Converts the [RequestVCQuery] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["selectedClaims"] = selectedClaims;
      data["filterConditions"] = filterConditions;
      return data;
    } catch (e) {
      print("Error in RequestVCQuery.toJson: $e");
      rethrow;
    }
  }
}
