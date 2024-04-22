import "package:infra_did_comm_dart/agent/agent.dart";
import "package:infra_did_comm_dart/messages/commons/context.dart";
import "package:infra_did_comm_dart/messages/commons/initiator.dart";
import "package:infra_did_comm_dart/messages/did_connect_request.dart";
import "package:infra_did_comm_dart/types/types.dart";

/// Executes a loop that sends DIDConnectRequestMessage to the agent until a DIDAuthInit message is received.
///
/// The loop sends the message with a specified interval of [loopTimeSeconds] seconds.
/// The [loopCallback] function is called with the encoded message as a parameter.
///
/// The loop starts by disconnecting the websocket client and then repeatedly connects and disconnects the client until a DIDAuthInit message is received.
/// The loop waits for a specified interval of [loopTimeSeconds] seconds between each message.
///
/// Parameters:
/// - [agent]: The InfraDIDCommAgent instance.
/// - [context]: The context for the DIDConnectRequestMessage.
/// - [loopTimeSeconds]: The interval between each message in seconds.
/// - [loopCallback]: The function to call with the encoded message.
///
/// Returns: A Future that completes when the loop is stopped.
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
