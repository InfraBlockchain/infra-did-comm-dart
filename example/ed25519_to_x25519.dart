import "package:convert/convert.dart";
import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

main() async {
  // Initialize Bob
  String bobSeed =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  List<int> bobPrivatekey = await privateKeyFromUri(bobSeed);
  List<int> bobPublicKey = await publicKeyFromUri(bobSeed);

  Map<String, dynamic> bobX25519JwkPrivateKey =
      await x25519JwkFromEd25519PrivateKey(bobPrivatekey);
  Map<String, dynamic> bobX25519JwkPublicKey =
      x25519JwkFromEd25519PublicKey(bobPublicKey);

  print(publicKeyfromX25519Jwk(bobX25519JwkPrivateKey));
  print(publicKeyfromX25519Jwk(bobX25519JwkPublicKey));
  print(privateKeyfromX25519Jwk(bobX25519JwkPrivateKey));
}
