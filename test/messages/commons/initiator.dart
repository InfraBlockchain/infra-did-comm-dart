import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";

void main() {
  test("Should make Initiator message", () {
    final initiator = Initiator(
      type: "HOLDER",
      serviceEndpoint: "https://wss.infradid.io",
      socketId: "12/Ph3SXvXZKCWQFoiwO5Qp",
    );
    expect(initiator.type, equals("HOLDER"));
    expect(initiator.serviceEndpoint, equals("https://wss.infradid.io"));
    expect(initiator.socketId, equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });

  test("Should make Initiator message from JSON", () {
    final initiator = {
      "type": "HOLDER",
      "serviceEndpoint": "https://wss.infradid.io",
      "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
    };
    final newInitiator = Initiator.fromJson(initiator);
    expect(newInitiator.type, equals("HOLDER"));
    expect(newInitiator.serviceEndpoint, equals("https://wss.infradid.io"));
    expect(newInitiator.socketId, equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });

  test("Should not make Initiator message from JSON with compact JSON", () {
    try {
      final initiator = {
        "se": "https://wss.infradid.io",
        "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
      };
      final newInitiator = Initiator.fromJson(initiator);
      expect(newInitiator, throwsException);
      expect(false, isTrue);
    } catch (e) {
      print(e);
      return;
    }
  });

  test("Should not make Initiator message from JSON with minimal compact JSON",
      () {
    try {
      final initiator = {
        "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
      };
      final newInitiator = Initiator.fromJson(initiator);
      expect(newInitiator, throwsException);
      expect(false, isTrue);
    } catch (e) {
      print(e);
      return;
    }
  });

  test("Should make Initiator message from compact JSON", () {
    final initiator = {
      "se": "https://wss.infradid.io",
      "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
    };
    final newInitiator = Initiator.fromCompactJson(initiator);
    expect(newInitiator.type, isNull);
    expect(newInitiator.serviceEndpoint, equals("https://wss.infradid.io"));
    expect(newInitiator.socketId, equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });

  test("Should not make Initiator message from compact JSON with JSON", () {
    try {
      final initiator = {
        "type": "HOLDER",
        "serviceEndpoint": "https://wss.infradid.io",
        "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
      };
      final newInitiator = Initiator.fromCompactJson(initiator);
      expect(newInitiator, throwsException);
      expect(false, isTrue);
    } catch (e) {
      print(e);
      return;
    }
  });

  test(
      "Should not make Initiator message from compact JSON with minimal compact JSON",
      () {
    final initiator = {
      "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
    };
    final newInitiator = Initiator.fromCompactJson(initiator);
    final newnewInitiator = newInitiator.toCompactJson();
    expect(newnewInitiator, isNot(equals(initiator)));
  });

  test("Should make Initiator message from minimal compact JSON", () {
    final initiator = {
      "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
    };
    final newInitiator = Initiator.fromMinimalCompactJson(initiator);
    expect(newInitiator.type, isNull);
    expect(newInitiator.serviceEndpoint, isNull);
    expect(newInitiator.socketId, equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });

  test("Should not make Initiator message from minimal compact JSON with JSON",
      () {
    try {
      final initiator = {
        "type": "HOLDER",
        "serviceEndpoint": "https://wss.infradid.io",
        "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
      };
      final newInitiator = Initiator.fromMinimalCompactJson(initiator);
      expect(newInitiator, throwsException);
      expect(false, isTrue);
    } catch (e) {
      print(e);
      return;
    }
  });

  test("Should export Initiator message to JSON", () {
    final initiator = Initiator(
      type: "HOLDER",
      serviceEndpoint: "https://wss.infradid.io",
      socketId: "12/Ph3SXvXZKCWQFoiwO5Qp",
    );
    final json = initiator.toJson();
    expect(json["type"], equals("HOLDER"));
    expect(json["serviceEndpoint"], equals("https://wss.infradid.io"));
    expect(json["socketId"], equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });

  test("Should export Initiator message to compact JSON", () {
    final initiator = Initiator(
      serviceEndpoint: "https://wss.infradid.io",
      socketId: "12/Ph3SXvXZKCWQFoiwO5Qp",
    );
    final json = initiator.toCompactJson();
    expect(json["se"], equals("https://wss.infradid.io"));
    expect(json["sid"], equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });

  test("Should export Initiator message to minimal compact JSON", () {
    final initiator = Initiator(socketId: "12/Ph3SXvXZKCWQFoiwO5Qp");
    final json = initiator.toCompactJson();
    expect(json["sid"], equals("12/Ph3SXvXZKCWQFoiwO5Qp"));
  });
}
