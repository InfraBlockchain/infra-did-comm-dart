import "package:cryptography/cryptography.dart";
import "dart:convert";

Future<(List<int>, List<int>)> generateX25519EphemeralKeyPair() async {
  final algorithm = X25519();
  final keyPair = await algorithm.newKeyPair();
  final publicKey = await keyPair.extractPublicKey();
  final privateKey = await keyPair.extractPrivateKeyBytes();
  return (privateKey, publicKey.bytes);
}

// Make 32-byte shared key from private key and public key
Future<List<int>> makeSharedKey(
  List<int> privateKey,
  List<int> publicKey,
) async {
  final algorithm = X25519();
  final sharedSecretKey = await algorithm.sharedSecretKey(
    keyPair: await algorithm.newKeyPairFromSeed(privateKey),
    remotePublicKey: SimplePublicKey(publicKey, type: KeyPairType.x25519),
  );
  return sharedSecretKey.extractBytes();
}

Future<Map<String, dynamic>> x25519JwkFromX25519PrivateKey(
  List<int> privateKey,
) async {
  final algorithm = X25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privateKey);
  final publicKey = await keyPair.extractPublicKey();
  final jwk = {
    "kty": "OKP",
    "crv": "X25519",
    "x": base64Url.encode(publicKey.bytes),
    "d": base64Url.encode(privateKey),
  };
  return jwk;
}

Map<String, dynamic> x25519JwkFromX25519PublicKey(List<int> publicKey) {
  final jwk = {
    "kty": "OKP",
    "crv": "X25519",
    "x": base64Url.encode(publicKey),
  };
  return jwk;
}

Future<Map<String, dynamic>> x25519FromEd25519PrivateKey(
  List<int> privateKey,
) async {
  final algorithm = X25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privateKey);
  final publicKey = await keyPair.extractPublicKey();
  final jwk = {
    "kty": "OKP",
    "crv": "X25519",
    "x": base64Url.encode(publicKey.bytes),
    "d": base64Url.encode(privateKey),
  };
  return jwk;
}

Map<String, dynamic> jwkFromSharedKey(List<int> sharedKey) {
  final jwk = {
    "kty": "oct",
    "k": base64Url.encode(sharedKey),
    "alg": "A256GCM",
  };
  return jwk;
}

List<int> publicKeyfromX25519Jwk(Map<String, dynamic> jwk) {
  Base64Codec base64 = const Base64Codec();
  final nomalizeBase64 = base64.normalize(jwk["x"]);
  return base64Url.decode(nomalizeBase64);
}

List<int> privateKeyfromX25519Jwk(Map<String, dynamic> jwk) {
  Base64Codec base64 = const Base64Codec();
  final nomalizeBase64 = base64.normalize(jwk["d"]);
  return base64Url.decode(nomalizeBase64);
}
