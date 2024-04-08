import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";

void main() {
  String privateKey =
      "1ce4a10a61dc92bd9dea6911d9ec96532aea66ecd48ab48574b9721066efd4731374cfe4890691403e134307f4a2b4b2e886f4b8498df4ef410e012ea0eb00ad";
  String publicKey =
      "1374cfe4890691403e134307f4a2b4b2e886f4b8498df4ef410e012ea0eb00ad";

  test("Should sign JWS", () {
    String data = "Hello, World!";
    String token = signJWS(data, privateKey);
    expect(token, isNotNull);
    print(token);
  });

  test("Should verify JWS", () {
    String token =
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJFZERTQSJ9.SGVsbG8sIFdvcmxkIQ.GLuyA2Y9Pg8LQyANYXM2sDMDM_TJJKnJpEx4O98EdNRsPQwqMSL_D9NRamRy8KFQvFUFfIFMqQSA_DXXvOWVCA";
    var payload = verifyJWS(token, publicKey);
    expect(payload, equals("Hello, World!"));
  });

  test("Should decode JWS", () {
    String token =
        "eyJ0eXAiOiJKV00iLCJhbGciOiJFZERTQSJ9.SGVsbG8sIFdvcmxkIQ.Si_Np1PQeXH7j7L346NfGlNy0QIm1_ikeXUB8_nShaWhkLhKFrVORDGkli0nrr0ccVMbtqN6mufNoaLU8wi7BA";
    var payload = decodeJWS(token);
    expect(payload, equals("Hello, World!"));
  });
}
