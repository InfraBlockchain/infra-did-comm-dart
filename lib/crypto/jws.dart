import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";
import "package:convert/convert.dart";

String signJWS(String data, String privateKey) {
  final jwt = JWT(data, header: {"typ": "JWM", "alg": "EdDSA"});

  // Key must be 64 bytes long
  final token = jwt.sign(
    EdDSAPrivateKey(hex.decode(privateKey)),
    algorithm: JWTAlgorithm.EdDSA,
  );

  return token;
}

dynamic verifyJWS(String token, String publicKey) {
  try {
    final jwt = JWT.verify(
      token,
      EdDSAPublicKey(hex.decode(publicKey)),
      checkHeaderType: false,
    );

    return jwt.payload;
  } on JWTExpiredException {
    print("jwt expired");
  } on JWTException catch (ex) {
    print(ex.message);
  }
}

dynamic decodeJWS(String token) {
  final jwt = JWT.decode(token);

  return jwt.payload;
}
