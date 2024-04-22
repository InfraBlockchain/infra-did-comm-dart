import "dart:typed_data";
import "package:convert/convert.dart";
import "package:substrate_bip39/substrate_bip39.dart";
import "package:polkadart_keyring/polkadart_keyring.dart";

/// Converts a URI to a public key.
///
/// Takes a URI as input and returns the corresponding public key as a list of integers.
/// The URI is used to generate a key pair using the ed25519 algorithm, and then the public key is extracted from the key pair.
Future<List<int>> publicKeyFromUri(String uri) async {
  final keypair = await KeyPair.ed25519.fromUri(uri);
  return keypair.publicKey.bytes;
}

/// Converts a seed to a public key.
///
/// Takes a seed as input and returns the corresponding public key as a list of integers.
/// The seed is used to generate a key pair using the ed25519 algorithm, and then the public key is extracted from the key pair.
List<int> publicKeyFromSeed(String seed) {
  final keypair =
      KeyPair.ed25519.fromSeed(Uint8List.fromList(hex.decode(seed)));
  return keypair.publicKey.bytes;
}

/// Converts a URI to a private key.
///
/// Takes a URI as input and returns the corresponding private key as a list of integers.
/// The URI is used to generate a seed using the ed25519 algorithm, and then the seed is returned as the private key.
Future<List<int>> privateKeyFromUri(String uri) async {
  final seed = await SubstrateBip39.ed25519.seedFromUri(uri);
  return seed;
}

/// Converts a URI to an extended private key.
///
/// Takes a URI as input and returns the corresponding extended private key as a list of integers.
/// The URI is used to generate a public key and a private key using the ed25519 algorithm.
/// The public key and private key are then concatenated to form the extended private key.
Future<List<int>> extendedPrivateKeyFromUri(String uri) async {
  final publicKey = await publicKeyFromUri(uri);
  final privateKey = await privateKeyFromUri(uri);
  List<int> extendedPrivateKey = [];
  extendedPrivateKey.addAll(privateKey);
  extendedPrivateKey.addAll(publicKey);
  return extendedPrivateKey;
}

/// Converts a seed to an extended private key.
///
/// Takes a seed as input and returns the corresponding extended private key as a list of integers.
/// The seed is used to generate a public key and a private key using the ed25519 algorithm.
/// The public key and private key are then concatenated to form the extended private key.
List<int> extendedPrivateKeyFromSeed(String seed) {
  final publicKey = publicKeyFromSeed(seed);
  final privateKey = hex.decode(seed);
  List<int> extendedPrivateKey = [];
  extendedPrivateKey.addAll(privateKey);
  extendedPrivateKey.addAll(publicKey);
  return extendedPrivateKey;
}

/// Converts an address to a public key.
///
/// Takes an address as input and returns the corresponding public key as a list of integers.
/// The address is decoded using the Keyring library, and then the decoded public key is returned.
List<int> publicKeyFromAddress(String address) {
  final keyring = Keyring();
  final decodedPublicKey = keyring.decodeAddress(address);
  return decodedPublicKey.toList();
}
