import "dart:async";

import "package:infra_did_comm_dart/messages/did_auth_init.dart";
import "package:infra_did_comm_dart/websocket/message_handler.dart";
import "package:socket_io_client/socket_io_client.dart" as IO;

class InfraDIDCommSocketClient {
  late IO.Socket socket;
  List<Map<String, String>> didList = [];

  final Completer<String?> _socketIdCompleter = Completer();
  Future<String?> get socketId => _socketIdCompleter.future;

  InfraDIDCommSocketClient(String url) {
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build(),
    );
    socket.onConnect((_) {
      print("Socket connected");
    });
    socket.onDisconnect((_) => print("Socket disconnected"));
  }

  void onConnect() {
    socket.on("connection", (data) {
      _socketIdCompleter.complete(socket.id);
      print("Socket ID: ${socket.id}");
    });
  }

  void connect() {
    socket.connect();
  }

  void disconnect() {
    socket.disconnect();
  }

  void onMessage(String mnemonic, String did, Function()? connectedCallback) {
    socket.on(
      "message",
      (data) => {messageHandler(data, mnemonic, did, this, connectedCallback)},
    );
  }

  Future<void> sendDIDAuthInitMessage(
    DIDAuthInitMessage authInitMessage,
    String mnemonic,
    String receiverDID,
  ) async {
    String message = await makeDIDAuthInitMessage(
        authInitMessage, mnemonic, receiverDID, this);
    socket.emit("message", {"to": authInitMessage.peerSocketId, "m": message});
    print("DIDAuthInitMessage sent to ${authInitMessage.peerSocketId}");
  }
}
