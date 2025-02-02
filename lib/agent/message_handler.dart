// ignore_for_file: library_prefixes

import "dart:convert";

import "package:convert/convert.dart";
import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:infra_did_dart/infra_did_dart.dart";
import "package:uuid/uuid.dart";

/// Handles incoming messages and performs necessary actions based on the message type.
///
/// The [messageHandler] function takes in the following parameters:
/// - [jwe]: The JWE (JSON Web Encryption) string representing the incoming message.
/// - [mnemonic]: The mnemonic string used for key generation.
/// - [did]: The DID (Decentralized Identifier) string.
/// - [agent]: An instance of the [InfraDIDCommAgent] class representing the agent.
/// - [didAuthCallback]: An optional callback function that is called when a DID Auth message is received.
/// - [didConnectedCallback]: An optional callback function that is called when a DID Connected message is received.
/// - [didAuthFailedCallback]: An optional callback function that is called when a DID Auth Failed message is received.
///
/// The [messageHandler] function handles different types of messages based on the algorithm specified in the JWE header.
/// If the algorithm is "ECDH-ES", it handles the DIDAuthInit message and sends a DID Auth message if successful.
/// If the algorithm is "dir", it handles both DIDAuth and DIDConnected messages.
///
/// Throws an exception if an error occurs during message handling.
Future<void> messageHandler(
  String jwe,
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  bool Function(String peerDID)? didAuthCallback,
  Function(String peerDID)? didConnectedCallback,
  Function(String peerDID)? didAuthFailedCallback,
  Future<Map<String, dynamic>> Function(
    List<RequestVC> requestVCs,
    String challenge,
  )? vpRequestCallback,
  bool Function(Map<String, dynamic> vp)? vpVerifyCallback,
  Function(SubmitVPResponseMessage message)? vpSubmitResCallback,
  Function(SubmitVPLaterResponseMessage message)? vpSubmitLaterResCallback,
  Function(RejectRequestVPMessage message)? vpRejectCallback,
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
      agent.peerInfo = {
        "did": jwsPayload["from"],
        "socketId": jwsPayload["body"]["socketId"],
      };
      agent.isReceivedDIDAuthInit = true;
      // If Success, Send DID Auth Message
      if (didAuthCallback != null) didAuthCallback(fromDID);
      sendDIDAuthMessage(mnemonic, jwsPayload, agent);
    }
    if (alg == "dir") {
      // Handle DIDAuth && DIDConnected Message
      List<int> privatekey = await privateKeyFromUri(mnemonic);
      Map<String, dynamic> x25519JwkPrivateKey =
          await x25519JwkFromEd25519PrivateKey(privatekey);
      if (agent.peerInfo.containsKey("did")) {
        String? fromDID = agent.peerInfo["did"];
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
          if (didAuthCallback != null) didAuthCallback(fromDID);
          sendDIDConnectedMessage(
            mnemonic,
            jwsPayload,
            agent,
          );
          if (agent.role == "VERIFIER") {
            agent.isDIDConnected = true;
          }
        }
        if (jwsPayload["type"] == "DIDConnected") {
          print("DIDConnected Message Received");
          if (didConnectedCallback != null) didConnectedCallback(fromDID);
          agent.isDIDConnected = true;
          if (agent.role == "VERIFIER") {
            sendDIDConnectedMessage(
              mnemonic,
              jwsPayload,
              agent,
            );
          }
        }
        if (jwsPayload["type"] == "DIDAuthFailed") {
          if (didAuthFailedCallback != null) didAuthFailedCallback(fromDID);
          print("DIDAuthFailed Message Received");
          agent.disconnect();
        }
        if (jwsPayload["type"] == "VPReq") {
          print("VPRequestMessage Message Received");
          if (vpRequestCallback != null) {
            Map<String, dynamic> result = await vpRequestCallback(
              (jwsPayload["body"]["vcRequirements"] as List<dynamic>)
                  .map<RequestVC>((vc) => RequestVC.fromJson(vc))
                  .toList(),
              jwsPayload["body"]["challenge"],
            );
            var status = result["status"] as String;
            if (status == VPRequestResponseType.submit.name) {
              var vp = result["vp"] as String;
              await sendSubmitVPMessage(
                mnemonic,
                did,
                agent,
                VPRequestMessage.fromJson(jwsPayload),
                vp,
              );
            } else if (status == VPRequestResponseType.reject.name) {
              var reason = result.containsKey("reason")
                  ? result["reason"] as String
                  : "Rejected";

              await sendRejectRequestVPMessage(
                mnemonic,
                did,
                agent,
                VPRequestMessage.fromJson(jwsPayload),
                reason,
              );
            } else if (status == VPRequestResponseType.submitLater.name) {
              await sendSubmitVPLaterMessage(
                mnemonic,
                did,
                agent,
                VPRequestMessage.fromJson(jwsPayload),
              );
            }
          }
        }
        if (jwsPayload["type"] == "VPSubmit") {
          bool isVerified = await verifyVP(
            jwsPayload["body"]["vp"],
            agent.vpChallenge,
          );

          if (vpVerifyCallback != null) {
            String jsonStringVP =
                utf8.decode(base64Url.decode(jwsPayload["body"]["vp"]));
            Map<String, dynamic> vp = json.decode(jsonStringVP);

            bool customVerification = vpVerifyCallback(vp);
            if (!customVerification) {
              isVerified = false;
            }
          }

          await sendSubmitVPResponseMessage(
            mnemonic,
            did,
            agent,
            SubmitVPMessage.fromJson(jwsPayload),
            isVerified,
          );
        }
        if (jwsPayload["type"] == "VPSubmitRes") {
          print("SubmitVPRes Message Received");
          if (vpSubmitResCallback != null) {
            vpSubmitResCallback(SubmitVPResponseMessage.fromJson(jwsPayload));
          }
        }
        if (jwsPayload["type"] == "VPReqReject") {
          if (vpRejectCallback != null) {
            vpRejectCallback(
              RejectRequestVPMessage.fromJson(jwsPayload),
            );
          }
          await sendRejectRequestVPResponseMessage(
            mnemonic,
            did,
            agent,
            RejectRequestVPMessage.fromJson(jwsPayload),
          );
        }
        if (jwsPayload["type"] == "VPReqRejectRes") {
          print("RejectReqVPRes Message Received");
        }
        if (jwsPayload["type"] == "VPSubmitLater") {
          await sendSubmitVPLaterResponseMessage(
            mnemonic,
            did,
            agent,
            SubmitVPLaterMessage.fromJson(jwsPayload),
            agent.vpLaterCallbackEndpoint,
          );
        }
        if (jwsPayload["type"] == "VPSubmitLaterRes") {
          print("SubmitVPLaterRes Message Received");
          if (vpSubmitLaterResCallback != null) {
            vpSubmitLaterResCallback(
              SubmitVPLaterResponseMessage.fromJson(jwsPayload),
            );
          }
        }
      }
    }
  } catch (e) {
    sendDIDAuthFailedMessage(mnemonic, did, agent);
    agent.disconnect();
    throw Exception("Error in message handling: $e");
  }
}

Future<void> sendSubmitVPLaterResponseMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  SubmitVPLaterMessage submitVPLaterMessage,
  String vpLaterCallbackEndpoint,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  SubmitVPLaterResponseMessage submitVPLaterResponseMessage =
      SubmitVPLaterResponseMessage(
    id: id,
    from: did,
    to: [submitVPLaterMessage.from],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    ack: [submitVPLaterMessage.id],
    callbackUrl: vpLaterCallbackEndpoint,
  );

  String? receiverSocketId = agent.peerInfo["socketId"];
  String receiverDID = submitVPLaterMessage.from;

  String jwe = await makeJWEFromMessage(
    mnemonic,
    receiverDID,
    agent,
    submitVPLaterResponseMessage.toJson(),
  );

  agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
  print("SubmitVPLaterResponseMessage sent to $receiverSocketId");
}

Future<void> sendRejectRequestVPResponseMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  RejectRequestVPMessage rejectRequestVPMessage,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  RejectRequestVPResponseMessage rejectRequestVPResponseMessage =
      RejectRequestVPResponseMessage(
    id: id,
    from: did,
    to: [rejectRequestVPMessage.from],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    ack: [rejectRequestVPMessage.id],
  );

  String? receiverSocketId = agent.peerInfo["socketId"];
  String receiverDID = rejectRequestVPMessage.from;

  String jwe = await makeJWEFromMessage(
    mnemonic,
    receiverDID,
    agent,
    rejectRequestVPResponseMessage.toJson(),
  );

  agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
  print("RejectRequestVPResponseMessage sent to $receiverSocketId");
}

Future<void> sendSubmitVPResponseMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  SubmitVPMessage submitVPMessage,
  bool isVerified,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  SubmitVPResponseMessage submitVPResponseMessage = SubmitVPResponseMessage(
    id: id,
    from: did,
    to: [submitVPMessage.from],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    ack: [submitVPMessage.id],
    status: isVerified ? "OK" : "Failed",
  );

  String? receiverSocketId = agent.peerInfo["socketId"];
  String receiverDID = submitVPMessage.from;

  String jwe = await makeJWEFromMessage(
    mnemonic,
    receiverDID,
    agent,
    submitVPResponseMessage.toJson(),
  );

  agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
  print("SubmitVPResponseMessage sent to $receiverSocketId");
}

Future<bool> verifyVP(
  String encodedVP,
  String challenge,
) async {
  try {
    String jsonStringVP = utf8.decode(base64Url.decode(encodedVP));
    Map<String, dynamic> vp = json.decode(jsonStringVP);

    if (vp["proofOptions"]["challenge"] != challenge) {
      return false;
    }

    InfraSS58DIDResolver resolver =
        InfraSS58DIDResolver("wss://did.stage.infrablockspace.net");
    bool isVerified =
        await InfraSS58VerifiablePresentation().verifyVp(vp, resolver);

    return isVerified;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<String> sendDIDAuthInitMessageToReceiver(
  DIDAuthInitMessage message,
  String mnemonic,
  String receiverDID,
  InfraDIDCommAgent agent,
) async {
  Map<String, dynamic> jsonMessage = message.toJson();
  String stringMessage = json.encode(jsonMessage);

  List<int> extendedPrivatekey = await extendedPrivateKeyFromUri(mnemonic);

  String receiverAddress = receiverDID.split(":").last;
  List<int> receiverPublicKey = publicKeyFromAddress(receiverAddress);
  agent.peerInfo = {"did": message.from, "socketId": message.peerSocketId};
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
  InfraDIDCommAgent agent,
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
    expiresTime: currentTime + 30000,
    context: Context.fromJson(didAuthInitMessagePayload["body"]["context"]),
    socketId: didAuthInitMessagePayload["body"]["peerSocketId"],
    peerSocketId: didAuthInitMessagePayload["body"]["socketId"],
  );

  String jwe = await makeJWEFromMessage(
    mnemonic,
    receiverDID,
    agent,
    didAuthMessage.toJson(),
  );

  agent.socket.emit("message", {"to": didAuthMessage.peerSocketId, "m": jwe});
  print("DIDAuthMessage sent to ${didAuthMessage.peerSocketId}");
}

Future<void> sendDIDConnectedMessage(
  String mnemonic,
  Map<String, dynamic> payload,
  InfraDIDCommAgent agent,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  String receiverDID = payload["from"];

  DIDConnectedMessage didConnectedMessage = DIDConnectedMessage(
    id: id,
    from: payload["to"][0],
    to: [receiverDID],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    context: Context.fromJson(payload["body"]["context"]),
    status: "Successfully Connected",
  );

  String jwe = await makeJWEFromMessage(
    mnemonic,
    receiverDID,
    agent,
    didConnectedMessage.toJson(),
  );

  agent.socket.emit(
    "message",
    {"to": payload["body"]["socketId"], "m": jwe},
  );
  print(
    "DIDConnectedMessage sent to ${payload["body"]["socketId"]}",
  );
}

Future<void> sendDIDAuthFailedMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent, {
  Context? context,
}) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  if (agent.peerInfo.containsKey("did")) {
    String? receiverDID = agent.peerInfo["did"];
    String? receiverSocketId = agent.peerInfo["socketId"];
    DIDAuthFailedMessage didAuthFailedMessage = DIDAuthFailedMessage(
      id: id,
      from: did,
      to: [receiverDID!],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context ?? Context(domain: "Infra DID Comm", action: "connect"),
      reason: "DID Auth Failed",
    );

    String jwe = await makeJWEFromMessage(
      mnemonic,
      receiverDID,
      agent,
      didAuthFailedMessage.toJson(),
    );
    agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
    print("DIDAuthFailed sent to $receiverSocketId");
  }
}

Future<void> sendSubmitVPMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  VPRequestMessage vpRequestMessage,
  String vp,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  SubmitVPMessage submitVPMessage = SubmitVPMessage(
    id: id,
    from: did,
    to: [vpRequestMessage.from],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    ack: [vpRequestMessage.id],
    vp: vp,
  );

  String? receiverSocketId = agent.peerInfo["socketId"];

  String jwe = await makeJWEFromMessage(
    mnemonic,
    agent.peerInfo["did"]!,
    agent,
    submitVPMessage.toJson(),
  );
  agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
  print("SubmitVPMessage sent to $receiverSocketId");
}

Future<void> sendRejectRequestVPMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  VPRequestMessage vpRequestMessage,
  String reason,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();

  RejectRequestVPMessage rejectRequestVPMessage = RejectRequestVPMessage(
    id: id,
    from: did,
    to: [vpRequestMessage.from],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    ack: [vpRequestMessage.id],
    reason: reason,
  );

  String? receiverSocketId = agent.peerInfo["socketId"];
  String jwe = await makeJWEFromMessage(
    mnemonic,
    agent.peerInfo["did"]!,
    agent,
    rejectRequestVPMessage.toJson(),
  );
  agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
  print("RejectRequestVPMessage sent to $receiverSocketId");
}

Future<void> sendSubmitVPLaterMessage(
  String mnemonic,
  String did,
  InfraDIDCommAgent agent,
  VPRequestMessage vpRequestMessage,
) async {
  int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  var uuid = Uuid();
  var id = uuid.v4();
  SubmitVPLaterMessage submitVPLaterMessage = SubmitVPLaterMessage(
    id: id,
    from: did,
    to: [vpRequestMessage.from],
    createdTime: currentTime,
    expiresTime: currentTime + 30000,
    ack: [vpRequestMessage.id],
  );

  String? receiverSocketId = agent.peerInfo["socketId"];

  String jwe = await makeJWEFromMessage(
    mnemonic,
    agent.peerInfo["did"]!,
    agent,
    submitVPLaterMessage.toJson(),
  );
  agent.socket.emit("message", {"to": receiverSocketId, "m": jwe});
  print("SubmitVPLaterMessage sent to $receiverSocketId");
}
