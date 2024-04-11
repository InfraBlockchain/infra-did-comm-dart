import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

bool didAuthInitCallback(String peerDID) {
  print("DID Auth Init Callback");
  return true;
}

bool didAuthCallback(String peerDID) {
  print("DID Auth Callback");
  return true;
}

void didConnectedCallback(String peerDID) {
  print("DID Connected Callback");
}

void didAuthFailedCallback(String peerDID) {
  print("DID Auth Failed Callback");
}

main() async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommSocketClient client = InfraDIDCommSocketClient(
    "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
  );

  client.setDIDAuthInitCallback(didAuthInitCallback);
  client.setDIDAuthCallback(didAuthCallback);
  client.setDIDConnectedCallback(didConnectedCallback);
  client.setDIDAuthFailedCallback(didAuthFailedCallback);

  client.onMessage();
  client.connect();

  String? socketId = await client.socketId;
  if (socketId != null) {
    String toSocketId = "3C9SxnIcgKlIvN0oAAFm";
    final minimalCompactJson = {
      "from": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "body": {
        "i": {"sid": toSocketId},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };
    final didConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(minimalCompactJson);

    String encoded = didConnectRequestMessage.encode(CompressionLevel.json);
    print("Holder make encoded request message: $encoded");
  } else {
    print("Socket ID is null");
  }
}
