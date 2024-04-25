import "dart:convert";

import "package:infra_did_comm_dart/crypto/jose_plus/jwe.dart";
import "package:infra_did_comm_dart/crypto/jose_plus/jwk.dart";
import "package:jwk/jwk.dart";

/// Encrypts the provided [data] using the specified [key] and optional [epk].
/// Returns the compact serialization of the encrypted JWE.
String encryptJWE(
  String data,
  Map<String, dynamic> key, {
  Map<String, dynamic>? epk,
}) {
  var keyJwk = JsonWebKey.fromJson(key);

  var builder = JsonWebEncryptionBuilder();
  builder.stringContent = data;
  builder.addRecipient(keyJwk, algorithm: "dir");
  builder.encryptionAlgorithm = "A256GCM";

  if (epk != null) {
    var epkJwk = Jwk.fromJson(epk);
    builder.setProtectedHeader("epk", epkJwk.toJson());
  }

  var jwe = builder.build();
  var split = jwe.toCompactSerialization().split(".");

  if (epk != null) {
    String jsonString = utf8.decode(base64Url.decode(split[0]));
    var jsonObject = json.decode(jsonString);
    jsonObject["alg"] = "ECDH-ES";
    split[0] = base64Url.encode(utf8.encode(json.encode(jsonObject)));
    if (split[0].length % 4 != 0) {
      var paddingLength = 4 - (split[0].length % 4);
      split[0] += "=" * paddingLength;
    }
  }

  return split.join(".");
}

/// Decrypts the provided [jweCompact] using the specified [key].
/// Returns the decrypted payload as a string.
Future<String> decryptJWE(String jweCompact, Map<String, dynamic> key) async {
  var split = jweCompact.split(".");
  if (split[0].length % 4 != 0) {
    var paddingLength = 4 - (split[0].length % 4);
    split[0] += "=" * paddingLength;
  }

  String jsonString = utf8.decode(base64Url.decode(split[0]));
  var jsonObject = json.decode(jsonString);
  if (jsonObject["alg"] == "ECDH-ES") {
    jsonObject["alg"] = "dir";
    split[0] = base64Url.encode(utf8.encode(json.encode(jsonObject)));
  }
  var jweString = split.join(".");

  var keyJwk = JsonWebKey.fromJson(key);
  var jwe = JsonWebEncryption.fromCompactSerialization(jweString);
  var keyStore = JsonWebKeyStore()..addKey(keyJwk);
  var payload = await jwe.getPayload(keyStore);

  return payload.stringContent;
}

/// Extracts and returns the header of the provided [jweCompact] as a map.
Map<String, dynamic> extractJWEHeader(String jweCompact) {
  var jwe = JsonWebEncryption.fromCompactSerialization(jweCompact);
  return jwe.commonProtectedHeader.toJson();
}
