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

  if (epk != null) {
    var epkJwk = Jwk.fromJson(epk);
    builder.addRecipient(keyJwk, algorithm: "ECDH-ES");
    builder.setProtectedHeader("epk", epkJwk.toJson());
  } else {
    builder.addRecipient(keyJwk, algorithm: "dir");
  }

  builder.encryptionAlgorithm = "A256GCM";

  var jwe = builder.build();
  return jwe.toCompactSerialization();
}

/// Decrypts the provided [jweCompact] using the specified [key].
/// Returns the decrypted payload as a string.
Future<String> decryptJWE(String jweCompact, Map<String, dynamic> key) async {
  var keyJwk = JsonWebKey.fromJson(key);

  var jwe = JsonWebEncryption.fromCompactSerialization(jweCompact);

  var keyStore = JsonWebKeyStore()..addKey(keyJwk);

  var payload = await jwe.getPayload(keyStore);

  return payload.stringContent;
}

/// Extracts and returns the header of the provided [jweCompact] as a map.
Map<String, dynamic> extractJWEHeader(String jweCompact) {
  var jwe = JsonWebEncryption.fromCompactSerialization(jweCompact);
  return jwe.commonProtectedHeader.toJson();
}
