class Initiator {
  String? type;
  String? serviceEndpoint;
  String socketId;

  Initiator({this.type, this.serviceEndpoint, required this.socketId});

  static Initiator fromJson(Map<String, dynamic> json) {
    try {
      final initiator = Initiator(
        type: json["type"],
        serviceEndpoint: json["serviceEndpoint"],
        socketId: json["socketId"],
      );

      return initiator;
    } catch (e) {
      rethrow;
    }
  }

  static Initiator fromCompactJson(Map<String, dynamic> json) {
    try {
      final initiator =
          Initiator(serviceEndpoint: json["se"], socketId: json["sid"]);

      return initiator;
    } catch (e) {
      rethrow;
    }
  }

  static Initiator fromMinimalCompactJson(Map<String, dynamic> json) {
    try {
      final initiator = Initiator(socketId: json["sid"]);

      return initiator;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["type"] = type;
      data["serviceEndpoint"] = serviceEndpoint;
      data["socketId"] = socketId;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toCompactJson() {
    try {
      final Map<String, dynamic> data = {};
      data["se"] = serviceEndpoint;
      data["sid"] = socketId;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toMinimalCompactJson() {
    try {
      final Map<String, dynamic> data = {};
      data["sid"] = socketId;
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
