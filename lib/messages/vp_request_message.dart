class VPRequestMessage {
  VPRequestMessage();

  factory VPRequestMessage.fromJson(Map<String, dynamic> json) {
    try {
      return VPRequestMessage();
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [VPRequestMessage] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
