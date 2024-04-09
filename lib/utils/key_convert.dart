import "dart:typed_data";
import "package:convert/convert.dart";
import "package:substrate_bip39/substrate_bip39.dart";
import "package:polkadart_keyring/polkadart_keyring.dart";

Future<List<int>> publicKeyFromUri(String uri) async {
  final keypair = await KeyPair.ed25519.fromUri(uri);
  return keypair.publicKey.bytes;
}

List<int> publicKeyFromSeed(String seed) {
  final keypair =
      KeyPair.ed25519.fromSeed(Uint8List.fromList(hex.decode(seed)));
  return keypair.publicKey.bytes;
}

Future<List<int>> privateKeyFromUri(String uri) async {
  final seed = await SubstrateBip39.ed25519.seedFromUri(uri);
  return seed;
}

Future<List<int>> extendedPrivateKeyFromUri(String uri) async {
  final publicKey = await publicKeyFromUri(uri);
  final privateKey = await privateKeyFromUri(uri);
  List<int> extendedPrivateKey = [];
  extendedPrivateKey.addAll(privateKey);
  extendedPrivateKey.addAll(publicKey);
  return extendedPrivateKey;
}

List<int> extendedPrivateKeyFromSeed(String seed) {
  final publicKey = publicKeyFromSeed(seed);
  final privateKey = hex.decode(seed);
  List<int> extendedPrivateKey = [];
  extendedPrivateKey.addAll(privateKey);
  extendedPrivateKey.addAll(publicKey);
  return extendedPrivateKey;
}

List<int> publicKeyFromAddress(String address) {
  final keyring = Keyring();
  final decodedPublicKey = keyring.decodeAddress(address);
  return decodedPublicKey.toList();
}
