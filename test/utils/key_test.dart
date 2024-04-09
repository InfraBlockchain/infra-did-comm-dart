import "package:convert/convert.dart";
import "package:infra_did_comm_dart/utils/key.dart";
import "package:test/test.dart";

void main() {
  String sk1 =
      "c01846b3121b359fc3811d9ba89d7881da2076f496dcc6e9a8123c0213f90d5f";
  String pk1 =
      "fa87cf7d2988d12264cb0b42a078dc5807e48fa1efb33f5fae2fb4f0e6940661";

  String sk2 =
      "90036ddffe69bb848350e944fa500157859dbca82b171732e8f5c1d9f1c13e63";
  String pk2 =
      "87bd990f3c7784fbdc93ef45bd967e5f1cbe1b082e9aedc9d305b877f1c50273";

  test("Should possible generate ephemeral keypair", () async {
    final keypair = await generateX25519EphemeralKeyPair();
    print("private key: ${hex.encode(keypair.$1)}");
    print("public key: ${hex.encode(keypair.$2)}");
  });

  test("Should possible to make shared key with x25519 keypair", () async {
    final sharedKey1 = await makeSharedKey(hex.decode(sk1), hex.decode(pk2));
    final sharedKey2 = await makeSharedKey(hex.decode(sk2), hex.decode(pk1));
    expect(sharedKey1, sharedKey2);
  });
}
