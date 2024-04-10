import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:uuid/uuid.dart";

void connectedCallback() {
  print("Connected");
}

main() async {
  InfraDIDCommSocketClient client =
      InfraDIDCommSocketClient("http://data-market.test.newnal.com:9000");
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  client.onConnect();
  client.onMessage(mnemonic, did, connectedCallback);
  client.connect();

  String? socketId = await client.socketId;
  if (socketId != null) {
    String toSocketId = "3C9SxnIcgKlIvN0oAAFm";
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthInitMessage didAuthInitMessage = DIDAuthInitMessage(
      id: id,
      from: did,
      to: [did],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      socketId: socketId,
      peerSocketId: toSocketId,
    );

    await client.sendDIDAuthInitMessage(
      didAuthInitMessage,
      mnemonic,
      did,
    );
  } else {
    print("Socket ID is null");
  }
}
