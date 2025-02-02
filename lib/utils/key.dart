import "dart:typed_data";
import "package:convert/convert.dart";
import "package:cryptography/cryptography.dart";
import "package:infra_did_comm_dart/utils/key_convert.dart";
import "dart:convert";
import "package:pinenacl/tweetnacl.dart";

/// Generates a X25519 ephemeral key pair.
/// Returns a Future that completes with a tuple containing the private key and the public key.
Future<(List<int>, List<int>)> generateX25519EphemeralKeyPair() async {
  final algorithm = X25519();
  final keyPair = await algorithm.newKeyPair();
  final publicKey = await keyPair.extractPublicKey();
  final privateKey = await keyPair.extractPrivateKeyBytes();
  return (privateKey, publicKey.bytes);
}

/// Makes a 32-byte shared key from the private key and the public key.
/// Returns a Future that completes with the shared key.
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

/// Converts a X25519 private key to a JWK (JSON Web Key) representation.
/// Returns a Future that completes with the JWK.
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

/// Converts a X25519 public key to a JWK (JSON Web Key) representation.
/// Returns the JWK.
Map<String, dynamic> x25519JwkFromX25519PublicKey(List<int> publicKey) {
  final jwk = {
    "kty": "OKP",
    "crv": "X25519",
    "x": base64Url.encode(publicKey),
  };
  return jwk;
}

/// Converts an Ed25519 public key to a X25519 public key and then to a JWK (JSON Web Key) representation.
/// Returns the JWK.
Map<String, dynamic> x25519JwkFromEd25519PublicKey(
  List<int> publicKey,
) {
  Uint8List x25519Pk = Uint8List.fromList(List.filled(32, 0));
  Uint8List ed25519Pk = Uint8List.fromList(publicKey);
  TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(x25519Pk, ed25519Pk);
  final jwk = {
    "kty": "OKP",
    "crv": "X25519",
    "x": base64Url.encode(x25519Pk),
  };
  return jwk;
}

/// Converts an Ed25519 private key to a X25519 private key and then to a JWK (JSON Web Key) representation.
/// Returns a Future that completes with the JWK.
Future<Map<String, dynamic>> x25519JwkFromEd25519PrivateKey(
  List<int> privateKey,
) async {
  Uint8List x25519Pk = Uint8List.fromList(List.filled(32, 0));
  Uint8List ed25519Pk =
      Uint8List.fromList(publicKeyFromSeed(hex.encode(privateKey)));
  TweetNaClExt.crypto_sign_ed25519_pk_to_x25519_pk(x25519Pk, ed25519Pk);
  Uint8List x25519Sk = Uint8List.fromList(List.filled(32, 0));
  Uint8List ed25519Sk = Uint8List.fromList(privateKey);
  TweetNaClExt.crypto_sign_ed25519_sk_to_x25519_sk(x25519Sk, ed25519Sk);

  final jwk = {
    "kty": "OKP",
    "crv": "X25519",
    "x": base64Url.encode(x25519Pk),
    "d": base64Url.encode(x25519Sk),
  };
  return jwk;
}

/// Converts a shared key to a JWK (JSON Web Key) representation.
/// Returns the JWK.
Map<String, dynamic> jwkFromSharedKey(List<int> sharedKey) {
  final jwk = {
    "kty": "oct",
    "k": base64Url.encode(sharedKey),
    "alg": "A256GCM",
  };
  return jwk;
}

/// Converts a X25519 JWK (JSON Web Key) to a X25519 public key.
/// Returns the X25519 public key.
List<int> publicKeyfromX25519Jwk(Map<String, dynamic> jwk) {
  Base64Codec base64 = const Base64Codec();
  final nomalizeBase64 = base64.normalize(jwk["x"]);
  return base64Url.decode(nomalizeBase64);
}

/// Converts a X25519 JWK (JSON Web Key) to a X25519 private key.
/// Returns the X25519 private key.
List<int> privateKeyfromX25519Jwk(Map<String, dynamic> jwk) {
  Base64Codec base64 = const Base64Codec();
  final nomalizeBase64 = base64.normalize(jwk["d"]);
  return base64Url.decode(nomalizeBase64);
}
