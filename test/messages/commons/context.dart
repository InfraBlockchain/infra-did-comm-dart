import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";

void main() {
  test("Should make Context message", () {
    final context = Context(domain: "context domain", action: "context action");
    expect(context.domain, equals("context domain"));
    expect(context.action, equals("context action"));
  });

  test("Should make Context message from JSON", () {
    final context = {
      "domain": "from JSON domain",
      "action": "from JSON action",
    };
    final newContext = Context.fromJson(context);
    expect(newContext.domain, equals("from JSON domain"));
    expect(newContext.action, equals("from JSON action"));
  });

  test("Should not make Context message from JSON with compact JSON", () {
    try {
      final context = {
        "d": "from JSON domain",
        "a": "from JSON action",
      };
      final newContext = Context.fromJson(context);
      expect(newContext, throwsException);
    } catch (e) {
      print(e);
      return;
    }
  });

  test("Should make Context message from compact JSON", () {
    final context = {
      "d": "compact JSON domain",
      "a": "compact JSON action",
    };
    final newContext = Context.fromCompactJson(context);
    expect(newContext.domain, equals("compact JSON domain"));
    expect(newContext.action, equals("compact JSON action"));
  });

  test("Should not make Context message from compact JSON with JSON", () {
    try {
      final context = {
        "domain": "from JSON domain",
        "action": "from JSON action",
      };
      final newContext = Context.fromCompactJson(context);
      expect(newContext, throwsException);
    } catch (e) {
      print(e);
      return;
    }
  });

  test("Should make Context message from minimal compact JSON", () {
    final context = {
      "d": "minimal compact JSON domain",
      "a": "minimal compact JSON action",
    };
    final newContext = Context.fromMinimalCompactJson(context);
    expect(newContext.domain, equals("minimal compact JSON domain"));
    expect(newContext.action, equals("minimal compact JSON action"));
  });

  test("Should not make Context message from minimal compact JSON with JSON",
      () {
    try {
      final context = {
        "domain": "from JSON domain",
        "action": "from JSON action",
      };
      final newContext = Context.fromMinimalCompactJson(context);
      expect(newContext, throwsException);
    } catch (e) {
      print(e);
      return;
    }
  });

  test("Should export Context message to JSON", () {
    final context =
        Context(domain: "compact JSON domain", action: "compact JSON action");
    final json = context.toJson();
    expect(json["domain"], equals("compact JSON domain"));
    expect(json["action"], equals("compact JSON action"));
  });

  test("Should export Context message to compact JSON", () {
    final context =
        Context(domain: "compact JSON domain", action: "compact JSON action");
    final json = context.toCompactJson();
    expect(json["d"], equals("compact JSON domain"));
    expect(json["a"], equals("compact JSON action"));
  });

  test("Should export Context message to minimal compact JSON", () {
    final context = Context(
      domain: "minimal compact JSON domain",
      action: "minimal compact JSON action",
    );
    final json = context.toCompactJson();
    expect(json["d"], equals("minimal compact JSON domain"));
    expect(json["a"], equals("minimal compact JSON action"));
  });
}
