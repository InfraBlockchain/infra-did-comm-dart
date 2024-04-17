import "dart:async";

import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

Future<void> didConnectRequestLoop(
  InfraDIDCommSocketClient client,
  Context context,
  int loopTimeSeconds,
  Function(String encodedMessage) loopCallback,
) async {
  // Disconnect the websocket client
  await client.disconnect();

  while (!client.isReceivedDIDAuthInit) {
    // Connect or reconnect the client
    await Future.delayed(Duration(milliseconds: 100));
    await client.disconnect();
    await Future.delayed(Duration(milliseconds: 100));
    await client.connect();

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await Future.delayed(Duration(milliseconds: 500));
    String socketId = (await client.socketId)!;

    Initiator initiator = Initiator(
      type: client.role,
      serviceEndpoint: client.url,
      socketId: socketId,
    );

    DIDConnectRequestMessage didConnectRequestMessage =
        DIDConnectRequestMessage(
      from: client.did,
      createdTime: currentTime,
      expiresTime: currentTime + loopTimeSeconds,
      context: context,
      initiator: initiator,
    );

    final encodedMessage =
        didConnectRequestMessage.encode(CompressionLevel.json);

    loopCallback(encodedMessage);

    // Wait for the specified loop time
    await Future.delayed(Duration(seconds: loopTimeSeconds));
  }
}
