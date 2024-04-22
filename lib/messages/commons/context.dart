/// Represents the context of an action in a domain.
class Context {
  String domain;
  String action;

  /// Creates a new instance of [Context].
  ///
  /// The [domain] and [action] parameters are required.
  Context({required this.domain, required this.action});

  /// Creates a [Context] instance from a JSON map.
  ///
  /// The [json] parameter is a map that contains the "domain" and "action" keys.
  /// Returns a [Context] instance.
  static Context fromJson(Map<String, dynamic> json) {
    try {
      final context = Context(domain: json["domain"], action: json["action"]);
      return context;
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a [Context] instance from a compact JSON map.
  ///
  /// The [json] parameter is a map that contains the "d" and "a" keys.
  /// Returns a [Context] instance.
  static Context fromCompactJson(Map<String, dynamic> json) {
    try {
      final context = Context(domain: json["d"], action: json["a"]);
      return context;
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a [Context] instance from a minimal compact JSON map.
  ///
  /// The [json] parameter is a map that contains the "d" and "a" keys.
  /// Returns a [Context] instance.
  static Context fromMinimalCompactJson(Map<String, dynamic> json) {
    try {
      return fromCompactJson(json);
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [Context] instance to a JSON map.
  ///
  /// Returns a JSON map representation of the [Context] instance.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      data["domain"] = domain;
      data["action"] = action;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [Context] instance to a compact JSON map.
  ///
  /// Returns a compact JSON map representation of the [Context] instance.
  Map<String, dynamic> toCompactJson() {
    try {
      final Map<String, dynamic> data = {};
      data["d"] = domain;
      data["a"] = action;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [Context] instance to a minimal compact JSON map.
  ///
  /// Returns a minimal compact JSON map representation of the [Context] instance.
  Map<String, dynamic> toMinimalCompactJson() {
    try {
      return toCompactJson();
    } catch (e) {
      rethrow;
    }
  }
}
