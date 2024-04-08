class Context {
  String domain;
  String action;

  Context({required this.domain, required this.action});

  static Context fromJson(Map<String, dynamic> json) {
    try {
      final context = Context(domain: json["domain"], action: json["action"]);
      return context;
    } catch (e) {
      rethrow;
    }
  }

  static Context fromCompactJson(Map<String, dynamic> json) {
    try {
      final context = Context(domain: json["d"], action: json["a"]);
      return context;
    } catch (e) {
      rethrow;
    }
  }

  static Context fromMinimalCompactJson(Map<String, dynamic> json) {
    try {
      return fromCompactJson(json);
    } catch (e) {
      rethrow;
    }
  }

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

  Map<String, dynamic> toMinimalCompactJson() {
    try {
      return toCompactJson();
    } catch (e) {
      rethrow;
    }
  }
}
