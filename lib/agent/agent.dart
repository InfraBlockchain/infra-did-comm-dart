import "dart:async";
import "dart:convert";
import "package:convert/convert.dart";
import "package:http/http.dart" as http;

import "package:infra_did_comm_dart/agent/message_handler.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;
import "package:uuid/uuid.dart";

import "../infra_did_comm_dart.dart";

/// Represents an InfraDIDComm agent that can connect to other agents and exchange messages.
class InfraDIDCommAgent {
  String did;
  String mnemonic;
  String role = "HOLDER";
  String url = "";

  late IO.Socket socket;
  late Map<String, String> peerInfo = {}; // peers' info {did, socketId}
  late String vpChallenge = "";
  late String vpLaterCallbackEndpoint = "";

  bool isDIDConnected = false;
  bool isReceivedDIDAuthInit = false;

  late bool Function(String peerDID) didAuthCallback = (String peerDID) => true;
  late Function(String peerDID) didConnectedCallback = (String peerDID) {};
  late Function(String peerDID) didAuthFailedCallback = (String peerDID) {};
  late Future<Map<String, dynamic>> Function(
    List<RequestVC> requestVCs,
    String challenge,
  ) vpRequestCallback = (List<RequestVC> requestVCs, String challenge) {
    return Future.value({"status": "reject"});
  };
  late bool Function(Map<String, dynamic> vp) vpVerifyCallback =
      (Map<String, dynamic> vp) => true;
  late Function(SubmitVPResponseMessage message) vpSubmitResCallback =
      (SubmitVPResponseMessage message) {};
  late Function(SubmitVPLaterResponseMessage message) vpSubmitLaterResCallback =
      (SubmitVPLaterResponseMessage message) {};
  late Function(RejectRequestVPMessage message) vpRejectCallback =
      (RejectRequestVPMessage message) {};

  Completer<String?> _socketIdCompleter = Completer();
  Future<String?> get socketId => _socketIdCompleter.future;

  /// Creates a new instance of [InfraDIDCommAgent].
  ///
  /// [url] - The URL of the server to connect to.
  /// [did] - The DID (Decentralized Identifier) of the agent.
  /// [mnemonic] - The mnemonic used for cryptographic operations.
  /// [role] - The role of the agent. Must be "HOLDER" or "VERIFIER".
  InfraDIDCommAgent({
    required this.url,
    required this.did,
    required this.mnemonic,
    required this.role,
  }) {
    url = url;
    did = did;
    mnemonic = mnemonic;
    if (role == "HOLDER" || role == "VERIFIER") {
      role = role;
    } else {
      throw Exception("Role must be HOLDER or VERIFIER");
    }
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );
    socket.on("connection", (data) {
      print("Socket ID: ${socket.id}");
    });
    socket.onConnect((_) {
      _socketIdCompleter.complete(socket.id);
      print("Socket connected");
    });
    socket.onDisconnect(
      (_) => {
        _socketIdCompleter = Completer(),
        print("Socket disconnected"),
      },
    );
    onMessage();
  }

  void changeRole(String newRole) {
    if (newRole == "HOLDER" || newRole == "VERIFIER") {
      role = newRole;
    } else {
      throw Exception("Role must be HOLDER or VERIFIER");
    }
  }

  /// Sets the callback function to be called when a DID authentication request is received.
  ///
  /// [callback] - The callback function that takes a peer DID as a parameter and returns a boolean indicating whether the authentication is accepted or not.
  void setDIDAuthCallback(bool Function(String peerDID) callback) {
    didAuthCallback = callback;
  }

  /// Sets the callback function to be called when a DID connection is established with a peer agent.
  ///
  /// [callback] - The callback function that takes a peer DID as a parameter.
  void setDIDConnectedCallback(Function(String peerDID) callback) {
    didConnectedCallback = callback;
  }

  /// Sets the callback function to be called when a DID authentication fails with a peer agent.
  ///
  /// [callback] - The callback function that takes a peer DID as a parameter.
  void setDIDAuthFailedCallback(Function(String peerDID) callback) {
    didAuthFailedCallback = callback;
  }

  void setVPRequestCallback(
    Future<Map<String, dynamic>> Function(
      List<RequestVC> requestVCs,
      String challenge,
    ) callback,
  ) {
    vpRequestCallback = callback;
  }

  void setVPVerifyCallback(bool Function(Map<String, dynamic> vp) callback) {
    vpVerifyCallback = callback;
  }

  void setVPSubmitResCallback(
      Function(SubmitVPResponseMessage message) callback) {
    vpSubmitResCallback = callback;
  }

  void setVPSubmitLaterResCallback(
    Function(SubmitVPLaterResponseMessage message) callback,
  ) {
    vpSubmitLaterResCallback = callback;
  }

  void setVPRejectCallback(
    Function(RejectRequestVPMessage message) callback,
  ) {
    vpRejectCallback = callback;
  }

  void setVPLaterCallbackEndpoint(String vpLaterCallbackEndpoint) {
    vpLaterCallbackEndpoint = vpLaterCallbackEndpoint;
  }

  /// Initializes the agent by setting up message handling and connecting to the server.
  init() async {
    await connect();
  }

  /// Initializes the agent with a connect request message and connects to the server.
  ///
  /// [encoded] - The encoded connect request message.
  initWithConnectRequest(String encoded) async {
    await connect();
    sendDIDAuthInitMessage(encoded);
  }

  /// Initializes the agent with a static connect request message and connects to the server.
  initWithStaticConnectRequest(
    String serviceEndpoint,
    Context context, {
    String? peerDID,
    bool Function(String peerDID)? didVerification,
  }) async {
    if (peerDID != null && didVerification != null) {
      if (!didVerification(peerDID)) {
        throw Exception("DID verification failed");
      }
    }

    // Initialize with static connection only can be done by HOLDER
    changeRole("HOLDER");
    await connect();

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await Future.delayed(Duration(milliseconds: 500));
    String socketId = (await this.socketId)!;

    Initiator initiator = Initiator(
      type: role,
      serviceEndpoint: url,
      socketId: socketId,
    );

    DIDConnectRequestMessage didConnectRequestMessage =
        DIDConnectRequestMessage(
      from: did,
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      initiator: initiator,
    );
    final encodedMessage =
        didConnectRequestMessage.encode(CompressionLevel.compactJSON);

    await http.get(Uri.parse("$serviceEndpoint?data=$encodedMessage"));
  }

  /// Initializes the agent with a DID request message loop and connects to the server.
  ///
  /// [context] - The context object.
  /// [loopTimeSeconds] - The time interval in seconds between each loop iteration.
  /// [loopCallback] - The callback function that takes an encoded message as a parameter and is called in each loop iteration.
  initWithDIDRequestMessageLoop(
    Context context,
    int loopTimeSeconds,
    Function(String encodedMessage) loopCallback,
  ) {
    didConnectRequestLoop(this, context, loopTimeSeconds, loopCallback);
  }

  /// Resets the agent by clearing peer information and flags.
  reset() {
    peerInfo = {};
    isReceivedDIDAuthInit = false;
    isDIDConnected = false;
  }

  /// Connects the agent to the server.
  connect() {
    socket.connect();
  }

  /// Disconnects the agent from the server.
  disconnect() {
    reset();
    socket.disconnect();
  }

  /// Sets up the message handling for the agent.
  void onMessage() {
    socket.on(
      "message",
      (data) => {
        messageHandler(
          data,
          mnemonic,
          did,
          this,
          didAuthCallback,
          didConnectedCallback,
          didAuthFailedCallback,
          vpRequestCallback,
          vpVerifyCallback,
          vpSubmitResCallback,
          vpSubmitLaterResCallback,
          vpRejectCallback,
        ),
      },
    );
  }

  /// Sends a DID authentication initialization message to a receiver agent.
  ///
  /// [encoded] - The encoded DID authentication initialization message.
  Future<void> sendDIDAuthInitMessage(String encoded) async {
    final didConnectRequestMessage = DIDConnectRequestMessage.decode(encoded);

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var uuid = Uuid();
    var id = uuid.v4();

    String receiverDID = didConnectRequestMessage.from;
    String peerSocketId = didConnectRequestMessage.initiator.socketId;
    DIDAuthInitMessage didAuthInitMessage = DIDAuthInitMessage(
      id: id,
      from: did,
      to: [receiverDID],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: didConnectRequestMessage.context,
      socketId: socket.id!,
      peerSocketId: didConnectRequestMessage.initiator.socketId,
    );

    String message = await sendDIDAuthInitMessageToReceiver(
      didAuthInitMessage,
      mnemonic,
      receiverDID,
      this,
    );
    peerInfo = {"did": receiverDID, "socketId": peerSocketId};
    socket.emit("message", {"to": peerSocketId, "m": message});
    print("DIDAuthInitMessage sent to $peerSocketId");
  }

  Future<void> sendVPRequestMessage(
    List<RequestVC> vcRequirements,
    String challenge,
  ) async {
    try {
      vpChallenge = challenge;

      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      var uuid = Uuid();
      var id = uuid.v4();
      String receiverDID = peerInfo["did"]!;
      VPRequestMessage vpRequestMessage = VPRequestMessage(
        id: id,
        from: did,
        to: [receiverDID],
        createdTime: currentTime,
        expiresTime: currentTime + 30000,
        vcRequirements: vcRequirements,
        challenge: challenge,
      );

      String peerSocketId = peerInfo["socketId"]!;
      String jwe = await makeJWEFromMessage(
        mnemonic,
        receiverDID,
        this,
        vpRequestMessage.toJson(),
      );
      socket.emit("message", {"to": peerSocketId, "m": jwe});
      print("VPRequestMessage sent to $peerSocketId");
    } catch (e) {
      throw Exception("Error in sendVPRequestMessage: $e");
    }
  }
}

Future<String> makeJWEFromMessage(
  String mnemonic,
  String receiverDID,
  InfraDIDCommAgent agent,
  Map<String, dynamic> jsonMessage,
) async {
  List<int> extendedPrivatekey = await extendedPrivateKeyFromUri(mnemonic);
  List<int> privatekey = await privateKeyFromUri(mnemonic);
  List<int> receiverpublicKey =
      publicKeyFromAddress(receiverDID.split(":").last);

  Map<String, dynamic> x25519JwkPrivateKey =
      await x25519JwkFromEd25519PrivateKey(privatekey);
  Map<String, dynamic> x25519JwkReceiverPublicKey =
      x25519JwkFromEd25519PublicKey(receiverpublicKey);

  String jws = signJWS(
    json.encode(jsonMessage),
    hex.encode(extendedPrivatekey),
  );
  List<int> sharedKey = await makeSharedKey(
    privateKeyfromX25519Jwk(x25519JwkPrivateKey),
    publicKeyfromX25519Jwk(x25519JwkReceiverPublicKey),
  );
  String jwe = encryptJWE(jws, jwkFromSharedKey(sharedKey));
  return jwe;
}
