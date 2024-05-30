import "dart:convert";

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

Map<String, dynamic> vpRequestCallback(
    List<RequestVC> requestVCs, String challenge) {
  // If want to reject the request, return the following JSON
  // return {
  //   "status": "reject",
  //   "reason": "I don't have the requested VC",
  // };

  // If want to submit later the requested VCs, return the following JSON
  // return {"status": "submitLater"};

  // If want to submit the requested VCs, return the following JSON
  String vp =
      '''{"@context":["https://www.w3.org/2018/credentials/v1","https://www.w3.org/2018/credentials/examples/v1"],"id":"did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z","type":["VerifiableCredential"],"credentialSubject":[{"id":"did:example:d23dd687a7dc6787646f2eb98d0"}],"issuanceDate":"2024-05-23T06:08:03.039Z","issuer":"did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z","proofOptions":{"@context":"https://w3id.org/security/suites/ed25519-2020/v1","type":"Ed25519","proofPurpose":"assertionMethod","verificationMethod":"did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z#key-2","created":"2024-05-30T05:05:23.826063Z","challenge":"challenge","proofValue":"z5ogf7czdcBwWmPy6ZmzpjsYYnSkWKwic3uF4Ac7otXcPQcPNidtAUsrULz3UwS4YxtaEV4J2AoMJCgSE7TZ794Bt"}}''';
  return {
    "status": "submit",
    "vp": deflateAndEncode(jsonDecode(vp)),
  };
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
  InfraDIDCommAgent agent = InfraDIDCommAgent(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER",
  );

  agent.setDIDAuthCallback(didAuthCallback);
  agent.setDIDConnectedCallback(didConnectedCallback);
  agent.setDIDAuthFailedCallback(didAuthFailedCallback);
  agent.setVPRequestCallback(vpRequestCallback);

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
    String verifierSocketId = "YUF-tN8SDHXa0k5EAAqp";
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
