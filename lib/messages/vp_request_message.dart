class VPRequestMessage {
  String id;
  String type = "VPReq";
  String from;
  List<String> to;
  int? createdTime;
  int? expiresTime;
  List<RequestVC> vcs;
  String challenge;

  VPRequestMessage({
    required this.id,
    required this.from,
    required this.to,
    this.createdTime,
    this.expiresTime,
    required this.vcs,
    required this.challenge,
  }) {
    id = id;
    from = from;
    to = to;
    createdTime = createdTime;
    expiresTime = expiresTime;
    vcs = vcs;
    challenge = challenge;
  }

  factory VPRequestMessage.fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey("type") && json["type"] != "VPReq") {
        throw Exception("Invalid type");
      }
      return VPRequestMessage(
        id: json["id"],
        from: json["from"],
        to: json["to"],
        createdTime:
            json.containsKey("created_time") ? json["created_time"] : 0,
        expiresTime:
            json.containsKey("expires_time") ? json["expires_time"] : 0,
        vcs: (json["body"]["VCs"] as List<dynamic>)
            .map<RequestVC>((vc) => RequestVC.fromJson(vc))
            .toList(),
        challenge: json["body"]["challenge"],
      );
    } catch (e) {
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
      data["created_time"] = createdTime;
      data["expires_time"] = expiresTime;
      data["body"] = {
        "VCs": vcs.map((vc) => vc.toJson()).toList(),
        "challenge": challenge
      };
      return data;
    } catch (e) {
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
      rethrow;
    }
  }

  /// Converts the [RequestVC] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["vc-type"] = vcType;
      data["query"] = query?.toJson();
      return data;
    } catch (e) {
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
        selectedClaims: json.containsKey("selected-claims")
            ? json["selected-claims"]
            : null,
        filterConditions: json.containsKey("filter-conditions")
            ? json["filter-conditions"]
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [RequestVCQuery] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["selected-claims"] = selectedClaims;
      data["filter-conditions"] = filterConditions;
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
