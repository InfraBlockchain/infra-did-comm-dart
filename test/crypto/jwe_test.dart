import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";

void main() {
  var jwkJson = {
    "kty": "oct",
    "k": "DyeSbxbuMmOArQWVriSFQ_BwI2m85_jZktOOVG1U2RA",
    "alg": "A256GCM",
  };

  var epkJson = {
    "kty": "OKP",
    "crv": "X25519",
    "x": "_LHSfmtWGx-eoy71sZD07prIWuFqmdJQEQ6RVRbDUA4",
  };

  test("Should encrypt JWE with epk", () {
    String data = "Hello, World!";
    String jweCompact = encryptJWE(data, jwkJson, epk: epkJson);
    expect(jweCompact, isNotNull);
    print(jweCompact);
  });

  test("Should decrypt JWE with epk", () async {
    String jwe =
        "eyJlcGsiOnsiY3J2IjoiWDI1NTE5Iiwia3R5IjoiT0tQIiwieCI6Il9MSFNmbXRXR3gtZW95NzFzWkQwN3BySVd1RnFtZEpRRVE2UlZSYkRVQTQifSwiZW5jIjoiQTI1NkdDTSIsImFsZyI6IkVDREgtRVMifQ==..Jqdn_CuaWkRAeuTP.6dG28r1Awl9sk-66Vw.MtQY1qAY1e25mIKwfiLbpA";
    String content = await decryptJWE(jwe, jwkJson);
    expect(content, isNotNull);
  });

  test("Should encrypt JWE without epk", () {
    String data = "Hello, World!";
    String jweCompact = encryptJWE(data, jwkJson);
    expect(jweCompact, isNotNull);
    print(jweCompact);
  });

  test("Should decrypt JWE without epk", () async {
    String jwe =
        "eyJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiZGlyIn0..NVLNRPYGVH7l4AbF.0qiqvSPbXLHxXKls1w.2zVcLQCTXhxatXymdMJZQg";
    String jweCompact = await decryptJWE(jwe, jwkJson);
    expect(jweCompact, isNotNull);
  });
}
