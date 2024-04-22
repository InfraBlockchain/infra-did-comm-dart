import "package:infra_did_comm_dart/infra_did_comm_dart.dart";

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
  // initiatedByHolderScenario();

  // If you want to run the initiatedByVerifierScenario, uncomment the line below
  initiatedByVerifierScenario();
}

initiatedByHolderScenario() async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommAgent agent = InfraDIDCommAgent(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER",
  );

  agent.setDIDAuthCallback(didAuthCallback);
  agent.setDIDConnectedCallback(didConnectedCallback);
  agent.setDIDAuthFailedCallback(didAuthFailedCallback);

  agent.init();

  String? socketId = await agent.socketId;
  if (socketId != null) {
    String holderSocketId = socketId;
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
    print("Holder make encoded request message: $encoded");
  } else {
    print("Socket ID is null");
  }
}

initiatedByVerifierScenario() async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommAgent agent = InfraDIDCommAgent(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER",
  );

  agent.setDIDAuthCallback(didAuthCallback);
  agent.setDIDConnectedCallback(didConnectedCallback);
  agent.setDIDAuthFailedCallback(didAuthFailedCallback);

  agent.init();

  String? socketId = await agent.socketId;
  if (socketId != null) {
    String verifierSocketId = "Wp6O6Tve6zEN35esAAXT";
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
    print("Received encoded request message from verifier: $encoded");
    await agent.sendDIDAuthInitMessage(encoded);
  } else {
    print("Socket ID is null");
  }
}