import "dart:async";

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

  bool isDIDConnected = false;
  bool isReceivedDIDAuthInit = false;

  late bool Function(String peerDID) didAuthCallback = (String peerDID) => true;
  late Function(String peerDID) didConnectedCallback = (String peerDID) {};
  late Function(String peerDID) didAuthFailedCallback = (String peerDID) {};

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

  /// Initializes the agent by setting up message handling and connecting to the server.
  init() {
    onMessage();
    connect();
  }

  /// Initializes the agent with a connect request message and connects to the server.
  ///
  /// [encoded] - The encoded connect request message.
  initWithConnectRequest(String encoded) {
    onMessage();
    connect();
    sendDIDAuthInitMessage(encoded);
  }

  /// Initializes the agent with a static connect request message and connects to the server.
  ///
  /// [encoded] - The encoded static connect request message.
  initWithStaticConnectRequest(String encoded) {
    onMessage();
    connect();
    // TODO: Implement this method
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
    onMessage();
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
}
