import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

void callback(String encodedMessage) {
  final currentTime = DateTime.now().toIso8601String();
  print("$currentTime: $encodedMessage");
  final decoded = DIDConnectRequestMessage.decode(encodedMessage);
  print(decoded.toJson());
  print("===================================");
}

main() async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommSocketClient client = InfraDIDCommSocketClient(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER",
  );
  final contextJson = {
    "domain": "infraDID",
    "action": "connect",
  };
  client.onMessage();
  final context = Context.fromJson(contextJson);
  int loopTimeSeconds = 30;

  didConnectRequestLoop(
    client,
    context,
    loopTimeSeconds,
    callback,
  );
}
