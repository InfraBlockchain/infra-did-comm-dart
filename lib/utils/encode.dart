import "dart:convert";
import "dart:io";

String deflateAndEncode(Map<String, dynamic> data) {
  String jsonString = json.encode(data);
  List<int> dataBytes = utf8.encode(jsonString);
  List<int> deflatedData = ZLibEncoder().convert(dataBytes);

  String encoded = base64Url.encode(deflatedData);
  return encoded;
}

Map<String, dynamic> inflateAndDecode(String encoded) {
  List<int> deflatedData = base64Url.decode(encoded);
  List<int> inflatedData = ZLibDecoder().convert(deflatedData);
  String jsonString = utf8.decode(inflatedData);
  Map<String, dynamic> data = json.decode(jsonString);
  return data;
}
