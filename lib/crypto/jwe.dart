import "package:infra_did_comm_dart/crypto/jose_plus/jwe.dart";
import "package:infra_did_comm_dart/crypto/jose_plus/jwk.dart";
import "package:jwk/jwk.dart";

String encryptJWE(String data, JsonWebKey key, {Jwk? epk}) {
  var builder = JsonWebEncryptionBuilder();
  builder.stringContent = data;

  if (epk != null) {
    builder.addRecipient(key, algorithm: "ECDH-ES");
    builder.setProtectedHeader("epk", epk.toJson());
  } else {
    builder.addRecipient(key, algorithm: "dir");
  }

  builder.encryptionAlgorithm = "A256GCM";

  var jwe = builder.build();
  return jwe.toCompactSerialization();
}

Future<String> decryptJWE(String jweCompact, JsonWebKey key) async {
  var jwe = JsonWebEncryption.fromCompactSerialization(jweCompact);

  var keyStore = JsonWebKeyStore()..addKey(key);

  var payload = await jwe.getPayload(keyStore);

  return payload.stringContent;
}
