import "dart:convert";

String deflateAndEncode(Map<String, dynamic> data) {
  String jsonString = json.encode(data);
  List<int> dataBytes = utf8.encode(jsonString);

  String encoded = base64Url.encode(dataBytes);
  return encoded;
}

Map<String, dynamic> inflateAndDecode(String encoded) {
  List<int> dataBytes = base64Url.decode(encoded);
  String jsonString = utf8.decode(dataBytes);
  Map<String, dynamic> data = json.decode(jsonString);
  return data;
}
