import "package:convert/convert.dart";
import "package:infra_did_comm_dart/utils/key_convert.dart";
import "package:test/test.dart";

void main() {
  String address = "5CWDU4cAf9sJbhD7gci6gP7jTTtXL1LsECuytVTBTzBBH6b3";
  String uri =
      "crunch host example village dragon urban chicken breeze winter fix satoshi lock";
  String privateKey =
      "1ce4a10a61dc92bd9dea6911d9ec96532aea66ecd48ab48574b9721066efd473"; // 32 bytes privatekey is seed
  String extendedPrivateKey =
      "1ce4a10a61dc92bd9dea6911d9ec96532aea66ecd48ab48574b9721066efd4731374cfe4890691403e134307f4a2b4b2e886f4b8498df4ef410e012ea0eb00ad";
  String publicKey =
      "1374cfe4890691403e134307f4a2b4b2e886f4b8498df4ef410e012ea0eb00ad";

  test("Should convert to publickey from uri", () async {
    final fromUri = await publicKeyFromUri(uri);
    expect(hex.encode(fromUri), publicKey);
  });

  test("Should convert to publickey from seed", () async {
    final fromSeed = publicKeyFromSeed(privateKey);
    expect(hex.encode(fromSeed), publicKey);
  });

  test("Should convert to privatekey from uri", () async {
    final fromUri = await privateKeyFromUri(uri);
    expect(hex.encode(fromUri), privateKey);
  });

  test("Should convert to extendedPrivatekey from uri", () async {
    final fromUri = await extendedPrivateKeyFromUri(uri);
    expect(hex.encode(fromUri), extendedPrivateKey);
  });

  test("Should convert to extendedPrivatekey from seed", () {
    final fromUri = extendedPrivateKeyFromSeed(privateKey);
    expect(hex.encode(fromUri), extendedPrivateKey);
  });

  test("Should convert to publicKey from address", () {
    final fromAddress = publicKeyFromAddress(address);
    expect(hex.encode(fromAddress), publicKey);
  });
}
