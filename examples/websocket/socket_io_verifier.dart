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
  // If you want to run the initiatedByHolderScenario, uncomment the line below
  initiatedByHolderScenario();

  // If you want to run the initiatedByVerifierScenario, uncomment the line below
  // initiatedByVerifierScenario();
}

initiatedByHolderScenario() async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommSocketClient client = InfraDIDCommSocketClient(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "VERIFIER",
  );

  client.setDIDAuthInitCallback(didAuthInitCallback);
  client.setDIDAuthCallback(didAuthCallback);
  client.setDIDConnectedCallback(didConnectedCallback);
  client.setDIDAuthFailedCallback(didAuthFailedCallback);

  client.onMessage();
  client.connect();

  String? socketId = await client.socketId;
  if (socketId != null) {
    String holderSocketId = "Sihuz9kg2cWz4gcdAAXz";
    final minimalCompactJson = {
      "from": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "body": {
        "i": {"sid": holderSocketId},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };
    final didConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(minimalCompactJson);

    String encoded = didConnectRequestMessage.encode(CompressionLevel.json);
    print("Received encoded request message from holder: $encoded");
    await client.sendDIDAuthInitMessage(encoded);
  } else {
    print("Socket ID is null");
  }
}

initiatedByVerifierScenario() async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommSocketClient client = InfraDIDCommSocketClient(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "VERIFIER",
  );

  client.setDIDAuthInitCallback(didAuthInitCallback);
  client.setDIDAuthCallback(didAuthCallback);
  client.setDIDConnectedCallback(didConnectedCallback);
  client.setDIDAuthFailedCallback(didAuthFailedCallback);

  client.onMessage();
  client.connect();

  String? socketId = await client.socketId;
  if (socketId != null) {
    String verifierSocketId = socketId;
    final minimalCompactJson = {
      "from": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "body": {
        "i": {"sid": verifierSocketId},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };
    final didConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(minimalCompactJson);

    String encoded = didConnectRequestMessage.encode(CompressionLevel.json);
    print("Verifier make encoded request message: $encoded");
  } else {
    print("Socket ID is null");
  }
}
