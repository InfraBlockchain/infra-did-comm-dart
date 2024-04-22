import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";
import "package:convert/convert.dart";

/// Signs the provided data using the private key and returns a JSON Web Signature (JWS) token.
///
/// The `data` parameter represents the data to be signed.
/// The `privateKey` parameter represents the private key used for signing.
/// The function returns the JWS token as a string.
String signJWS(String data, String privateKey) {
  final jwt = JWT(data, header: {"typ": "JWM", "alg": "EdDSA"});

  // Key must be 64 bytes long
  final token = jwt.sign(
    EdDSAPrivateKey(hex.decode(privateKey)),
    algorithm: JWTAlgorithm.EdDSA,
  );

  return token;
}

/// Verifies the provided JWS token using the public key and returns the payload if the verification is successful.
///
/// The `token` parameter represents the JWS token to be verified.
/// The `publicKey` parameter represents the public key used for verification.
/// The function returns the payload of the JWS token if the verification is successful, otherwise it returns null.
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

/// Decodes the provided JWS token and returns the payload.
///
/// The `token` parameter represents the JWS token to be decoded.
/// The function returns the payload of the JWS token.
dynamic decodeJWS(String token) {
  final jwt = JWT.decode(token);

  return jwt.payload;
}
