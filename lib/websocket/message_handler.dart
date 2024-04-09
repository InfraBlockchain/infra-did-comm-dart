// ignore_for_file: library_prefixes

import "dart:convert";

import "package:convert/convert.dart";
import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;
import "package:uuid/uuid.dart";

Future<void> messageHandler(
  String jwe,
  String mnemonic,
  String did,
  InfraDIDCommSocketClient client,
  Function()? connectedCallback,
) async {
  try {
    Map<String, dynamic> header = extractJWEHeader(jwe);
    String alg = header["alg"];
    if (alg == "ECDH-ES") {
      // Handle DIDAuthInit Message
      Map<String, dynamic> epk = header["epk"];
      List<int> privatekey = await privateKeyFromUri(mnemonic);
      Map<String, dynamic> x25519JwkPrivateKey =
          await x25519JwkFromEd25519PrivateKey(privatekey);
      List<int> sharedKey = await makeSharedKey(
        privateKeyfromX25519Jwk(x25519JwkPrivateKey),
        publicKeyfromX25519Jwk(epk),
      );
      String jwsFromJwe = await decryptJWE(jwe, jwkFromSharedKey(sharedKey));
      var payload = decodeJWS(jwsFromJwe);
      String fromDID = payload["from"];
      String fromAddress = fromDID.split(":").last;
      List<int> fromPublicKey = publicKeyFromAddress(fromAddress);
      Map<String, dynamic> jwsPayload =
          verifyJWS(jwsFromJwe, hex.encode(fromPublicKey));
      print(jwsPayload);
      // If Success, Send DID Auth Message
      sendDIDAuthMessage(mnemonic, jwsPayload, client.socket);
    }
    if (alg == "dir") {
      // Handle DIDAuth && DIDConnected Message
      List<int> privatekey = await privateKeyFromUri(mnemonic);
      Map<String, dynamic> x25519JwkPrivateKey =
          await x25519JwkFromEd25519PrivateKey(privatekey);
      if (client.peerInfo.isNotEmpty) {
        String? fromDID = client.peerInfo[0]["did"];
        String fromAddress = fromDID!.split(":").last;
        List<int> fromPublicKey = publicKeyFromAddress(fromAddress);
        Map<String, dynamic> x25519JwkPublicKey =
            x25519JwkFromEd25519PublicKey(fromPublicKey);

        List<int> sharedKey = await makeSharedKey(
          privateKeyfromX25519Jwk(x25519JwkPrivateKey),
          publicKeyfromX25519Jwk(x25519JwkPublicKey),
        );
        String jwsFromJwe = await decryptJWE(jwe, jwkFromSharedKey(sharedKey));
        Map<String, dynamic> jwsPayload =
            verifyJWS(jwsFromJwe, hex.encode(fromPublicKey));
        if (jwsPayload["type"] == "DIDAuth") {
          // If Success, Send DID Connected Message
          sendDIDConnectedMessage(mnemonic, jwsPayload, client.socket);
        }
        if (jwsPayload["type"] == "DIDConnected") {
          print("DIDConnected Message Received");
          client.isConnected = true;
          if (connectedCallback != null) connectedCallback();
        }
        if(jwsPayload["type"] == "DIDAuthFailed") {
          client.peerInfo.clear();
          print("DIDAuthFailed Message Received");
          client.socket.disconnect();
        }
      }
    }
  } catch (e) {
    client.peerInfo.clear();
    sendDIDAuthFailedMessage(mnemonic, did, client);
    client.socket.disconnect();
  }
}

Future<String> makeDIDAuthInitMessage(
  DIDAuthInitMessage message,
  String mnemonic,
  String receiverDID,
  InfraDIDCommSocketClient client,
) async {
  Map<String, dynamic> jsonMessage = message.toJson();
  String stringMessage = json.encode(jsonMessage);

  List<int> extendedPrivatekey = await extendedPrivateKeyFromUri(mnemonic);

  String receiverAddress = receiverDID.split(":").last;
  List<int> receiverPublicKey = publicKeyFromAddress(receiverAddress);
  client.peerInfo.add({"did": message.from, "socketId": message.peerSocketId});
  String jws = signJWS(stringMessage, hex.encode(extendedPrivatekey));

  final ephemeralKeyPair = await generateX25519EphemeralKeyPair();
  List<int> ephemeralPrivateKey = ephemeralKeyPair.$1;
  List<int> ephemeralPublicKey = ephemeralKeyPair.$2;

  Map<String, dynamic> x25519JwkPublicKey =
      x25519JwkFromEd25519PublicKey(receiverPublicKey);

  List<int> sharedKey = await makeSharedKey(
    ephemeralPrivateKey,
    publicKeyfromX25519Jwk(x25519JwkPublicKey),
  );

  String jwe = encryptJWE(
    jws,
    jwkFromSharedKey(sharedKey),
    epk: x25519JwkFromX25519PublicKey(ephemeralPublicKey),
  );

  return jwe;
}

Future<void> sendDIDAuthMessage(
  String mnemonic,
  Map<String, dynamic> didAuthInitMessagePayload,
  IO.Socket socket,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  String receiverDID = didAuthInitMessagePayload["from"];
  DIDAuthMessage didAuthMessage = DIDAuthMessage(
    id: id,
    from: didAuthInitMessagePayload["to"][0],
    to: [receiverDID],
    createdTime: currentTime,
    expiresTime: currentTime + 1000,
    context: Context.fromJson(didAuthInitMessagePayload["body"]["context"]),
    socketId: didAuthInitMessagePayload["body"]["peerSocketId"],
    peerSocketId: didAuthInitMessagePayload["body"]["socketId"],
  );

  List<int> extendedPrivatekey = await extendedPrivateKeyFromUri(mnemonic);
  List<int> privatekey = await privateKeyFromUri(mnemonic);
  List<int> receiverpublicKey =
      publicKeyFromAddress(receiverDID.split(":").last);

  Map<String, dynamic> x25519JwkPrivateKey =
      await x25519JwkFromEd25519PrivateKey(privatekey);
  Map<String, dynamic> x25519JwkReceiverPublicKey =
      x25519JwkFromEd25519PublicKey(receiverpublicKey);

  String jws = signJWS(
    json.encode(didAuthMessage.toJson()),
    hex.encode(extendedPrivatekey),
  );
  List<int> sharedKey = await makeSharedKey(
    privateKeyfromX25519Jwk(x25519JwkPrivateKey),
    publicKeyfromX25519Jwk(x25519JwkReceiverPublicKey),
  );
  String jwe = encryptJWE(jws, jwkFromSharedKey(sharedKey));
  socket.emit("message", {"to": didAuthMessage.peerSocketId, "m": jwe});
  print("DIDAuthMessage sent to ${didAuthMessage.peerSocketId}");
}

Future<void> sendDIDConnectedMessage(
  String mnemonic,
  Map<String, dynamic> didAuthMessagePayload,
  IO.Socket socket,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  String receiverDID = didAuthMessagePayload["from"];
  DIDConnectedMessage didConnectedMessage = DIDConnectedMessage(
    id: id,
    from: didAuthMessagePayload["to"][0],
    to: [receiverDID],
    createdTime: currentTime,
    expiresTime: currentTime + 1000,
    context: Context.fromJson(didAuthMessagePayload["body"]["context"]),
    status: "Successfully Connected",
  );

  List<int> extendedPrivatekey = await extendedPrivateKeyFromUri(mnemonic);
  List<int> privatekey = await privateKeyFromUri(mnemonic);
  List<int> receiverpublicKey =
      publicKeyFromAddress(receiverDID.split(":").last);

  Map<String, dynamic> x25519JwkPrivateKey =
      await x25519JwkFromEd25519PrivateKey(privatekey);
  Map<String, dynamic> x25519JwkReceiverPublicKey =
      x25519JwkFromEd25519PublicKey(receiverpublicKey);

  String jws = signJWS(
    json.encode(didConnectedMessage.toJson()),
    hex.encode(extendedPrivatekey),
  );
  List<int> sharedKey = await makeSharedKey(
    privateKeyfromX25519Jwk(x25519JwkPrivateKey),
    publicKeyfromX25519Jwk(x25519JwkReceiverPublicKey),
  );
  String jwe = encryptJWE(jws, jwkFromSharedKey(sharedKey));
  socket.emit(
    "message",
    {"to": didAuthMessagePayload["body"]["socketId"], "m": jwe},
  );
  print(
    "DIDConnectedMessage sent to ${didAuthMessagePayload["body"]["socketId"]}",
  );
}

Future<void> sendDIDAuthFailedMessage(
  String mnemonic,
  String did,
  InfraDIDCommSocketClient client, {
  Context? context,
}) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  if (client.peerInfo.isNotEmpty) {
    String? receiverDID = client.peerInfo[0]["did"];
    String? receiverSocketId = client.peerInfo[0]["socketId"];
    DIDAuthFailedMessage didAuthFailedMessage = DIDAuthFailedMessage(
      id: id,
      from: did,
      to: [receiverDID!],
      createdTime: currentTime,
      expiresTime: currentTime + 1000,
      context: context ?? Context(domain: "Infra DID Comm", action: "connect"),
      reason: "DID Auth Failed",
    );

    List<int> extendedPrivatekey = await extendedPrivateKeyFromUri(mnemonic);
    List<int> privatekey = await privateKeyFromUri(mnemonic);
    List<int> receiverpublicKey =
        publicKeyFromAddress(receiverDID.split(":").last);

    Map<String, dynamic> x25519JwkPrivateKey =
        await x25519JwkFromEd25519PrivateKey(privatekey);
    Map<String, dynamic> x25519JwkReceiverPublicKey =
        x25519JwkFromEd25519PublicKey(receiverpublicKey);

    String jws = signJWS(
      json.encode(didAuthFailedMessage.toJson()),
      hex.encode(extendedPrivatekey),
    );
    List<int> sharedKey = await makeSharedKey(
      privateKeyfromX25519Jwk(x25519JwkPrivateKey),
      publicKeyfromX25519Jwk(x25519JwkReceiverPublicKey),
    );
    String jwe = encryptJWE(jws, jwkFromSharedKey(sharedKey));
    client.socket.emit("message", {"to": receiverSocketId, "m": jwe});
    print("DIDAuthFailed sent to $receiverSocketId");
  }
}
