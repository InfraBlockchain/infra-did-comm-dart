import "package:infra_did_comm_dart/crypto/jose_plus/jwe.dart";
import "package:infra_did_comm_dart/crypto/jose_plus/jwk.dart";
import "package:jwk/jwk.dart";

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

Future<String> decryptJWE(String jweCompact, Map<String, dynamic> key) async {
  var keyJwk = JsonWebKey.fromJson(key);

  var jwe = JsonWebEncryption.fromCompactSerialization(jweCompact);

  var keyStore = JsonWebKeyStore()..addKey(keyJwk);

  var payload = await jwe.getPayload(keyStore);

  return payload.stringContent;
}

Map<String, dynamic> extractJWEHeader(String jweCompact) {
  var jwe = JsonWebEncryption.fromCompactSerialization(jweCompact);
  return jwe.commonProtectedHeader.toJson();
}
