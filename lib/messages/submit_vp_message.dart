class SubmitVPMessage {
  SubmitVPMessage();

  factory SubmitVPMessage.fromJson(Map<String, dynamic> json) {
    try {
      return SubmitVPMessage();
    } catch (e) {
      rethrow;
    }
  }

  /// Converts the [SubmitVPMessage] instance to a JSON map.
  Map<String, dynamic> toJson() {
    try {
      final Map<String, dynamic> data = {};
      return data;
    } catch (e) {
      rethrow;
    }
  }
}
