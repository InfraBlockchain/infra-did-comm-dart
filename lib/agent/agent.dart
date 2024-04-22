import "dart:async";

import "package:infra_did_comm_dart/agent/message_handler.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;
import "package:uuid/uuid.dart";

import "../infra_did_comm_dart.dart";

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

  void setDIDAuthCallback(bool Function(String peerDID) callback) {
    didAuthCallback = callback;
  }

  void setDIDConnectedCallback(Function(String peerDID) callback) {
    didConnectedCallback = callback;
  }

  void setDIDAuthFailedCallback(Function(String peerDID) callback) {
    didAuthFailedCallback = callback;
  }

  init() {
    onMessage();
    connect();
  }

  initWithConnectRequest(String encoded) {
    onMessage();
    connect();
    sendDIDAuthInitMessage(encoded);
  }

  initWithStaticConnectRequest(String encoded) {
    onMessage();
    connect();
    // TODO: Implement this method
  }

  initWithDIDRequestMessageLoop(
    Context context,
    int loopTimeSeconds,
    Function(String encodedMessage) loopCallback,
  ) {
    onMessage();
    didConnectRequestLoop(this, context, loopTimeSeconds, loopCallback);
  }

  reset() {
    peerInfo = {};
    isReceivedDIDAuthInit = false;
    isDIDConnected = false;
  }

  connect() {
    socket.connect();
  }

  disconnect() {
    reset();
    socket.disconnect();
  }

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
