import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:jose_plus/jose.dart";
import "package:test/test.dart";

void main() {
  var jwk = JsonWebKey.fromJson({
    "kty": "oct",
    "k": "DyeSbxbuMmOArQWVriSFQ_BwI2m85_jZktOOVG1U2RA",
    "alg": "A256GCM",
  });

  test("Should encrypt JWE", () {
    String data = "Hello, World!";
    String jweCompact = encryptJWE(data, jwk!);
    expect(jweCompact, isNotNull);
    print(jweCompact);
  });

  test("Should decrypt JWE", () async {
    String jwe =
        "eyJlbmMiOiJBMjU2R0NNIiwiYWxnIjoiZGlyIiwia2lkIjoiMDU4OTc2NjEtZThiZS00YjcwLTlmMzUtYWY1YzNiMGZhZDU2In0..3BzT2yMdYfk73HaH.raL0ul1rJIn_tOEbDA.fyZ9y2clSgP5lUtVnoh6dA";
    String jweCompact = await decryptJWE(jwe, jwk!);
    expect(jweCompact, isNotNull);
  });
}
