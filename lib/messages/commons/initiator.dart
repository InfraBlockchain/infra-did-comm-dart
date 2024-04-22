/// Represents an Initiator in the communication process.
class Initiator {
  String? type;
  String? serviceEndpoint;
  String socketId;

  /// Constructs an [Initiator] object.
  ///
  /// The [type] is the type of the initiator.
  /// The [serviceEndpoint] is the service endpoint of the initiator.
  /// The [socketId] is the socket ID of the initiator.
  Initiator({this.type, this.serviceEndpoint, required this.socketId});

  /// Creates an [Initiator] object from a JSON map.
  ///
  /// The [json] parameter is a JSON map representing the [Initiator] object.
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

  /// Creates an [Initiator] object from a compact JSON map.
  ///
  /// The [json] parameter is a compact JSON map representing the [Initiator] object.
  static Initiator fromCompactJson(Map<String, dynamic> json) {
    try {
      final initiator =
          Initiator(serviceEndpoint: json["se"], socketId: json["sid"]);

      return initiator;
    } catch (e) {
      rethrow;
    }
  }

  /// Creates an [Initiator] object from a minimal compact JSON map.
  ///
  /// The [json] parameter is a minimal compact JSON map representing the [Initiator] object.
  static Initiator fromMinimalCompactJson(Map<String, dynamic> json) {
    try {
      final initiator = Initiator(socketId: json["sid"]);

      return initiator;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [Initiator] object to a JSON map.
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

  /// Converts the [Initiator] object to a compact JSON map.
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

  /// Converts the [Initiator] object to a minimal compact JSON map.
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
