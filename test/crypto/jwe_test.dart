import "package:infra_did_comm_dart/crypto/jose_plus/jwk.dart";
import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:jwk/jwk.dart";
import "package:test/test.dart";

void main() {
  var jwk = JsonWebKey.fromJson({
    "kty": "oct",
    "k": "DyeSbxbuMmOArQWVriSFQ_BwI2m85_jZktOOVG1U2RA",
    "alg": "A256GCM",
  });

  var epk = Jwk.fromJson({
    "kty": "OKP",
    "crv": "X25519",
    "x": "_LHSfmtWGx-eoy71sZD07prIWuFqmdJQEQ6RVRbDUA4",
  });

  test("Should encrypt JWE with epk", () {
    String data = "Hello, World!";
    String jweCompact = encryptJWE(data, jwk!, epk: epk!);
    expect(jweCompact, isNotNull);
    print(jweCompact);
  });

  test("Should decrypt JWE with epk", () async {
    String jwe =
        "eyJlcGsiOnsiY3J2IjoiWDI1NTE5Iiwia3R5IjoiT0tQIiwieCI6Il9MSFNmbXRXR3gtZW95NzFzWkQwN3BySVd1RnFtZEpRRVE2UlZSYkRVQTQifSwiZW5jIjoiQTI1NkdDTSIsImFsZyI6IkVDREgtRVMifQ..3RYYbk9FM4d9ss6D.E7SQthAsSbYU8fjNQA.NBeTGa_bzFJM0oLcwnbj6Q";
    String jweCompact = await decryptJWE(jwe, jwk!);
    expect(jweCompact, isNotNull);
  });

  test("Should encrypt JWE without epk", () {
    String data = "Hello, World!";
    String jweCompact = encryptJWE(data, jwk!!);
    expect(jweCompact, isNotNull);
    print(jweCompact);
  });

  test("Should decrypt JWE without epk", () async {
    String jwe =
        "eyJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiZGlyIn0..NVLNRPYGVH7l4AbF.0qiqvSPbXLHxXKls1w.2zVcLQCTXhxatXymdMJZQg";
    String jweCompact = await decryptJWE(jwe, jwk!);
    expect(jweCompact, isNotNull);
  });
}
