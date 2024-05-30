import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:infra_did_comm_dart/types/types.dart";
import "package:test/test.dart";

void main() {
  test("Should make DID-Connect-Request Message", () {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    Initiator initiator = Initiator(
      type: "t",
      serviceEndpoint: "se",
      socketId: "sid",
    );

    DIDConnectRequestMessage didConnectRequestMessage =
        DIDConnectRequestMessage(
      from: "f",
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      initiator: initiator,
    );
    expect(didConnectRequestMessage.from, "f");
    expect(didConnectRequestMessage.createdTime, currentTime);
    expect(didConnectRequestMessage.expiresTime, currentTime + 30000);
    expect(didConnectRequestMessage.context.domain, "d");
    expect(didConnectRequestMessage.context.action, "a");
  });

  test("Should make DID-Connect-Request Message from JSON", () {
    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "initiator": {
          "type": "HOLDER",
          "serviceEndpoint": "https://wss.infradid.io",
          "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "context": {"domain": "pet-i.net", "action": "connect"},
      },
    };

    final newDIDConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(message);
    expect(
      newDIDConnectRequestMessage.from,
      "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
    );
    expect(newDIDConnectRequestMessage.createdTime, 1662441420);
    expect(newDIDConnectRequestMessage.expiresTime, 1662441435);
    expect(newDIDConnectRequestMessage.context.domain, "pet-i.net");
    expect(newDIDConnectRequestMessage.context.action, "connect");
    expect(newDIDConnectRequestMessage.initiator.type, "HOLDER");
    expect(
      newDIDConnectRequestMessage.initiator.serviceEndpoint,
      "https://wss.infradid.io",
    );
    expect(
      newDIDConnectRequestMessage.initiator.socketId,
      "12/Ph3SXvXZKCWQFoiwO5Qp",
    );
  });

  test("Should make DID-Connect-Request Message from compact JSON", () {
    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "i": {
          "se": "https://wss.infradid.io",
          "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };

    final newDIDConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(message);
    expect(
      newDIDConnectRequestMessage.from,
      "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
    );
    expect(newDIDConnectRequestMessage.createdTime, 1662441420);
    expect(newDIDConnectRequestMessage.expiresTime, 1662441435);
    expect(newDIDConnectRequestMessage.context.domain, "pet-i.net");
    expect(newDIDConnectRequestMessage.context.action, "connect");
    expect(
      newDIDConnectRequestMessage.initiator.serviceEndpoint,
      "https://wss.infradid.io",
    );
    expect(
      newDIDConnectRequestMessage.initiator.socketId,
      "12/Ph3SXvXZKCWQFoiwO5Qp",
    );
  });

  test("Should make DID-Connect-Request Message from minimal compact JSON", () {
    final message = {
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "body": {
        "i": {"sid": "12/Ph3SXvXZKCWQFoiwO5Qp"},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };

    final newDIDConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(message);
    expect(
      newDIDConnectRequestMessage.from,
      "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
    );
    expect(newDIDConnectRequestMessage.context.domain, "pet-i.net");
    expect(newDIDConnectRequestMessage.context.action, "connect");
    expect(
      newDIDConnectRequestMessage.initiator.socketId,
      "12/Ph3SXvXZKCWQFoiwO5Qp",
    );
  });

  test("Should possible DID-Connect-Request Message to JSON", () {
    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "initiator": {
          "type": "HOLDER",
          "serviceEndpoint": "https://wss.infradid.io",
          "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "context": {"domain": "pet-i.net", "action": "connect"},
      },
    };

    final newDIDConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(message);

    final json = newDIDConnectRequestMessage.toJson();
    expect(message, equals(json));
  });

  test("Should possible DID-Connect-Request Message to compact JSON", () {
    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "initiator": {
          "type": "HOLDER",
          "serviceEndpoint": "https://wss.infradid.io",
          "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "context": {"domain": "pet-i.net", "action": "connect"},
      },
    };

    final newDIDConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(message);

    final json = newDIDConnectRequestMessage.toCompactJson();
    final compactJson = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "i": {
          "se": "https://wss.infradid.io",
          "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };

    expect(json, equals(compactJson));
  });

  test("Should possible DID-Connect-Request Message to minimal compact JSON",
      () {
    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "initiator": {
          "type": "HOLDER",
          "serviceEndpoint": "https://wss.infradid.io",
          "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "context": {"domain": "pet-i.net", "action": "connect"},
      },
    };

    final newDIDConnectRequestMessage =
        DIDConnectRequestMessage.fromJson(message);

    final json = newDIDConnectRequestMessage.toMinimalCompactJson();
    final minimalCompactJson = {
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "body": {
        "i": {"sid": "12/Ph3SXvXZKCWQFoiwO5Qp"},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };
    expect(json, equals(minimalCompactJson));
  });

  test("Should encode DID-Connect-Request Message", () {
    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "initiator": {
          "type": "HOLDER",
          "serviceEndpoint": "https://wss.infradid.io",
          "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "context": {"domain": "pet-i.net", "action": "connect"},
      },
    };

    final didConnectRequestMessage = DIDConnectRequestMessage.fromJson(message);

    String encoded = didConnectRequestMessage.encode(CompressionLevel.json);
    expect(encoded, isA<String>());
    String compactEncoded =
        didConnectRequestMessage.encode(CompressionLevel.compactJSON);
    expect(compactEncoded, isA<String>());
    String minimalCompactEncoded =
        didConnectRequestMessage.encode(CompressionLevel.minimalCompactJSON);
    expect(minimalCompactEncoded, isA<String>());

    print(encoded);
    print(compactEncoded);
    print(minimalCompactEncoded);
  });

  test("Should decode encoded DID-Connect-Request Message", () {
    String encoded =
        "eyJ0eXBlIjoiRElEQ29ubmVjdFJlcSIsImZyb20iOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzhLZUZYVUtCUjlrY3RtM2VhZnMydGdxSzNYeGNxc25IdFJwMmtqU2RmREZTbjN4NGJLIiwiY3JlYXRlZF90aW1lIjoxNjYyNDQxNDIwLCJleHBpcmVzX3RpbWUiOjE2NjI0NDE0MzUsImJvZHkiOnsiaW5pdGlhdG9yIjp7InR5cGUiOiJIT0xERVIiLCJzZXJ2aWNlRW5kcG9pbnQiOiJodHRwczovL3dzcy5pbmZyYWRpZC5pbyIsInNvY2tldElkIjoiMTIvUGgzU1h2WFpLQ1dRRm9pd081UXAifSwiY29udGV4dCI6eyJkb21haW4iOiJwZXQtaS5uZXQiLCJhY3Rpb24iOiJjb25uZWN0In19fQ==";

    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "initiator": {
          "type": "HOLDER",
          "serviceEndpoint": "https://wss.infradid.io",
          "socketId": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "context": {"domain": "pet-i.net", "action": "connect"},
      },
    };

    final didConnectRequestMessage = DIDConnectRequestMessage.decode(encoded);
    expect(didConnectRequestMessage.toJson(), equals(message));
  });

  test("Should decode compact encoded DID-Connect-Request Message", () {
    String compactEncoded =
        "eyJ0eXBlIjoiRElEQ29ubmVjdFJlcSIsImZyb20iOiJkaWQ6aW5mcmE6MDE6UFVCX0sxXzhLZUZYVUtCUjlrY3RtM2VhZnMydGdxSzNYeGNxc25IdFJwMmtqU2RmREZTbjN4NGJLIiwiY3JlYXRlZF90aW1lIjoxNjYyNDQxNDIwLCJleHBpcmVzX3RpbWUiOjE2NjI0NDE0MzUsImJvZHkiOnsiaSI6eyJzZSI6Imh0dHBzOi8vd3NzLmluZnJhZGlkLmlvIiwic2lkIjoiMTIvUGgzU1h2WFpLQ1dRRm9pd081UXAifSwiYyI6eyJkIjoicGV0LWkubmV0IiwiYSI6ImNvbm5lY3QifX19";

    final compactJson = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "createdTime": 1662441420,
      "expiresTime": 1662441435,
      "body": {
        "i": {
          "se": "https://wss.infradid.io",
          "sid": "12/Ph3SXvXZKCWQFoiwO5Qp",
        },
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };

    final didConnectRequestMessage =
        DIDConnectRequestMessage.decode(compactEncoded);
    expect(didConnectRequestMessage.toCompactJson(), equals(compactJson));
  });

  test("Should decode minimal compact encoded DID-Connect-Request Message", () {
    String minimalCompactEncoded =
        "eyJmcm9tIjoiZGlkOmluZnJhOjAxOlBVQl9LMV84S2VGWFVLQlI5a2N0bTNlYWZzMnRncUszWHhjcXNuSHRScDJralNkZkRGU24zeDRiSyIsImJvZHkiOnsiaSI6eyJzaWQiOiIxMi9QaDNTWHZYWktDV1FGb2l3TzVRcCJ9LCJjIjp7ImQiOiJwZXQtaS5uZXQiLCJhIjoiY29ubmVjdCJ9fX0=";

    final minimalCompactJson = {
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "body": {
        "i": {"sid": "12/Ph3SXvXZKCWQFoiwO5Qp"},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };

    final didConnectRequestMessage =
        DIDConnectRequestMessage.decode(minimalCompactEncoded);
    expect(didConnectRequestMessage.toMinimalCompactJson(),
        equals(minimalCompactJson));
  });
}
