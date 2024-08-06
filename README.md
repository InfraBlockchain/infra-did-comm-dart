# infra-did-comm-dart

Feature provided by infra-did-comm-dart Library :

-   Make DID-Connect-Request Message
-   Make DID-Auth-Init Message
-   Make DID-Auth Message
-   Make DID-Connected Message
-   Make DID-Auth-Failed Message
-   Sign / Verify JWS
-   Encrypt / Decrypt JWE
-   Convert Key Ed25519 to X25519
-   Make shared key using ECDH-ES
-   Connect to Websocket Server
-   Make Dynamic QR Code
-  Make VP Request Message

## Installation

-   **Using [pub](https://pub.dev)**:

```sh
dart pub add infra_did_comm_dart # this not work now cause we are not published yet
dart pub add infra_did_comm_dart --git-url=https://github.com/InfraBlockchain/infra-did-comm-dart.git # you can add with git url
```

## Examples

Get more examples in [example](./example) and [test](./test) folder.

### Holder & Verifier

* Holder

```dart
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

Future<Map<String, dynamic>> vpRequestCallback(
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
  return Future.value({
    "status": "submit",
    "vp": jsonDecode(vp),
  });
}

main() async {
  initiatedByHolderScenario();
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
```

* Verifier

```dart
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
  String encoded = "" // Get from Holder
  initiatedByHolderScenario(encoded);
}

initiatedByHolderScenario(String encoded) async {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommAgent agent = InfraDIDCommAgent(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "VERIFIER",
  );

  agent.setDIDAuthCallback(didAuthCallback);
  agent.setDIDConnectedCallback(didConnectedCallback);
  agent.setDIDAuthFailedCallback(didAuthFailedCallback);

  agent.init();
  await agent.sendDIDAuthInitMessage(encoded);
  if (agent.isDIDConnected) {
    print("DID is connected");
    agent.sendVPReq([], "challenge");
  }
}
```
