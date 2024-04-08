import "package:jose_plus/jose.dart";

String encryptJWE(String data, JsonWebKey key) {
  var builder = JsonWebEncryptionBuilder();
  builder.stringContent = data;

  builder.addRecipient(key, algorithm: "dir");

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
