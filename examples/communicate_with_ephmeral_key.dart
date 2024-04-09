import "package:convert/convert.dart";
import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

Future<void> main() async {
  // Initialize Alice
  String aliceSeed =
      "shallow job before mask maple monster room leisure smoke primary seek excuse";
  List<int> aliceExtendedPrivatekey =
      await extendedPrivateKeyFromUri(aliceSeed);
  List<int> alicePublicKey = await publicKeyFromUri(aliceSeed);

  // Initialize Bob
  String bobSeed =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  List<int> bobPrivatekey = await privateKeyFromUri(bobSeed);
  List<int> bobPublicKey = await publicKeyFromUri(bobSeed);
  Map<String, dynamic> bobX25519JwkPrivateKey =
      await x25519JwkFromEd25519PrivateKey(bobPrivatekey);
  Map<String, dynamic> bobX25519JwkPublicKey =
      x25519JwkFromEd25519PublicKey(bobPublicKey);

  // Alice make ephemeral keypair
  final ephemeralKeyPair = await generateX25519EphemeralKeyPair();
  List<int> ephemeralPrivateKey = ephemeralKeyPair.$1;
  List<int> ephemeralPublicKey = ephemeralKeyPair.$2;

  // Alice make shared key with ephmeral private key and bob's public key
  // Need to publicKeyfromX25519Jwk(bobX25519JwkPrivateKey) << get from Resolver
  List<int> sharedKey1 = await makeSharedKey(
    ephemeralPrivateKey,
    publicKeyfromX25519Jwk(bobX25519JwkPublicKey),
  );

  print("Alice make shared key1: ${hex.encode(sharedKey1)}");

  // Alice make JWS
  String data = "Hello World!";
  String jws = signJWS(data, hex.encode(aliceExtendedPrivatekey));
  String jwe = encryptJWE(jws, jwkFromSharedKey(sharedKey1),
      epk: x25519JwkFromX25519PublicKey(ephemeralPublicKey));

  // Get ephmeral public key
  Map<String, dynamic> header = extractJWEHeader(jwe);
  Map<String, dynamic> epk = header["epk"];

  // Bob make shared key with Bob's private key and ephmeral public key
  List<int> sharedKey2 = await makeSharedKey(
    privateKeyfromX25519Jwk(bobX25519JwkPrivateKey),
    publicKeyfromX25519Jwk(epk),
  );
  print("Bob makes shared key2: ${hex.encode(sharedKey2)}");
  String jwsFromJwe = await decryptJWE(jwe, jwkFromSharedKey(sharedKey2));
  print("jwsFromJwe: $jwsFromJwe");
  var jwsPayload = verifyJWS(jwsFromJwe, hex.encode(alicePublicKey));
  print("jwsPayload: $jwsPayload");
}
