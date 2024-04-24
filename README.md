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

## Installation

-   **Using [pub](https://pub.dev)**:

```sh
dart pub add infra_did_comm_dart # this not work now cause we are not published yet
dart pub add infra_did_comm_dart --git-url=https://github.com/InfraBlockchain/infra-did-comm-dart.git # you can add with git url
```

## Examples

Get more examples in [examples](./examples) and [test](./test) folder.

### Make DID-Connect-Request Message

```dart
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "some-domain",
      action: "connect",
    );
    Initiator initiator = Initiator(
      type: "HOLDER",
      serviceEndpoint: "http://localhost:8000",
      socketId: "3C9SxnIcgKlIvN00AAFm",
    );
```

### Make DID-Auth-Init Message

```dart
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "some-domain",
      action: "connect",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthInitMessage didAuthInitMessage = DIDAuthInitMessage(
      id: id,
      from: "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      to: ["did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      socketId: "3C9SxnIcgKlIvN00AAFm",
      peerSocketId: "O2kcsMxfKsh5gKFzAAFW",
    );
```

### Make DID-Auth Message

```dart
   int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "some-domain",
      action: "connect",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthMessage didAuthMessage = DIDAuthMessage(
      id: id,
      from: "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      to: ["did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      socketId: "3C9SxnIcgKlIvN00AAFm",
      peerSocketId: "O2kcsMxfKsh5gKFzAAFW",
    );
```

### Make DID-Connected Message

```dart
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "some-domain",
      action: "connect",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDConnectedMessage didConnectedMessage = DIDConnectedMessage(
      id: id,
      from: "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      to: ["did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      status: "Connected",
    );
```

### Make DID-Auth-Failed Message

```dart
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "some-domain",
      action: "connect",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthFailedMessage didAuthFailedMessage = DIDAuthFailedMessage(
      id: id,
      from: "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      to: ["did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      reason: "Invalid Signature",
    );
```

### Sign / Verify JWS

```dart
String data = "Hello, World!";
String token = signJWS(data, privateKey);

var payload = verifyJWS(token, publicKey);
```

### Encrypt / Decrypt JWE

* With epk

```dart
  String bobSeed =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  List<int> bobPrivatekey = await privateKeyFromUri(bobSeed);
  List<int> bobPublicKey = await publicKeyFromUri(bobSeed);

  final ephemeralKeyPair = await generateX25519EphemeralKeyPair();
  List<int> ephemeralPrivateKey = ephemeralKeyPair.$1;
  List<int> ephemeralPublicKey = ephemeralKeyPair.$2;

  List<int> sharedKey = await makeSharedKey(
    ephemeralPrivateKey,
    publicKeyfromX25519Jwk(bobX25519JwkPublicKey),
  );

  String data = "Hello, World!";
  String jweCompact = encryptJWE(data, jwkFromSharedKey(sharedKey), epk: x25519JwkFromX25519PublicKey(ephemeralPublicKey));
  String content = await decryptJWE(jweCompact, sharedKey);
```

* Without epk

```dart
  var jwkJson = {
    "kty": "oct",
    "k": "DyeSbxbuMmOArQWVriSFQ_BwI2m85_jZktOOVG1U2RA",
    "alg": "A256GCM",
  };

    String data = "Hello, World!";
    String jweCompact = encryptJWE(data, jwkJson);
    String content = await decryptJWE(content, jwkJson);
```

### Convert Key Ed25519 to X25519

```dart
  String bobSeed =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  List<int> bobPrivatekey = await privateKeyFromUri(bobSeed);
  List<int> bobPublicKey = await publicKeyFromUri(bobSeed);

  Map<String, dynamic> bobX25519JwkPrivateKey =
      await x25519JwkFromEd25519PrivateKey(bobPrivatekey);
  Map<String, dynamic> bobX25519JwkPublicKey =
      x25519JwkFromEd25519PublicKey(bobPublicKey);

  print(publicKeyfromX25519Jwk(bobX25519JwkPrivateKey));
  print(publicKeyfromX25519Jwk(bobX25519JwkPublicKey));
  print(privateKeyfromX25519Jwk(bobX25519JwkPrivateKey));
```

### Make shared key using ECDH-ES

```dart
 // Using X25519 key
  String sk1 =
      "c01846b3121b359fc3811d9ba89d7881da2076f496dcc6e9a8123c0213f90d5f";
  String pk1 =
      "fa87cf7d2988d12264cb0b42a078dc5807e48fa1efb33f5fae2fb4f0e6940661";

  String sk2 =
      "90036ddffe69bb848350e944fa500157859dbca82b171732e8f5c1d9f1c13e63";
  String pk2 =
      "87bd990f3c7784fbdc93ef45bd967e5f1cbe1b082e9aedc9d305b877f1c50273";
    final sharedKey1 = await makeSharedKey(hex.decode(sk1), hex.decode(pk2));
    final sharedKey2 = await makeSharedKey(hex.decode(sk2), hex.decode(pk1));
```

### Connect to Websocket Server

Check [example](./examples/socket-io) for more detail.

```dart
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  InfraDIDCommAgent agent = InfraDIDCommAgent(
    "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER", // HOLDER or VERIFIER
  );

  agent.setDIDAuthInitCallback(didAuthInitCallback);
  agent.setDIDAuthCallback(didAuthCallback);
  agent.setDIDConnectedCallback(didConnectedCallback);
  agent.setDIDAuthFailedCallback(didAuthFailedCallback);

  agent.init();
```

### Make Dynamic QR Code

```dart
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
  InfraDIDCommAgent agent = InfraDIDCommAgent(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER",
  );
  final contextJson = {
    "domain": "infraDID",
    "action": "connect",
  };
  final context = Context.fromJson(contextJson);
  int loopTimeSeconds = 15;

  didConnectRequestLoop(
    client,
    context,
    loopTimeSeconds,
    callback,
  );
}
```