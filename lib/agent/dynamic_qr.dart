import "dart:async";

import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

Future<void> didConnectRequestLoop(
  InfraDIDCommAgent agent,
  Context context,
  int loopTimeSeconds,
  Function(String encodedMessage) loopCallback,
) async {
  // Disconnect the websocket client
  await agent.disconnect();

  while (!agent.isReceivedDIDAuthInit) {
    // Connect or reconnect the client
    await Future.delayed(Duration(milliseconds: 100));
    await agent.disconnect();
    await Future.delayed(Duration(milliseconds: 100));
    await agent.connect();

    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await Future.delayed(Duration(milliseconds: 500));
    String socketId = (await agent.socketId)!;

    Initiator initiator = Initiator(
      type: agent.role,
      serviceEndpoint: agent.url,
      socketId: socketId,
    );

    DIDConnectRequestMessage didConnectRequestMessage =
        DIDConnectRequestMessage(
      from: agent.did,
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
