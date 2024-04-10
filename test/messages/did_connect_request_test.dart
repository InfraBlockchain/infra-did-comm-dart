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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
        "eJxdUE1vgkAQ_S97piAfmpajItHQRMWYkl4I7g51Sthd2IliDP-9S-2px3nv5X3Mg9FdA4tZsk1WSkrglEPHHFb3qrWwQBGjrPsqnvnx_rQsM798zSAtTtkyf2s4tSFUtQnoq8vCYuCdkRvKddB8H0WdpEcZDtE5s368h4pAlIStjfMXiyCK_CiYOQwGjT2Yf0w4d9hZiTuLHwwlElak-un467vZvSfr3Bob6K_IYS2FVijJUhcibWLPuxnj_na3I1xUk1bxBmgrrMgPvP0lPBbX4jNbfRxShbfd_KDZaKsqSTDQFCZUW6G0cg30gq4Esi4VJ1QTyJ8PY-M4_gClkmuy";

    final message = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
        "eJxdj0FvgzAMhf-LzwxKoNWWY4vQphzWgqqhXRBNTJtVhECslarivy9st10s2c9-7_MD6G4ROGRv2a43BiUVOEAA7dh3fqy04tq0Y8NXMd8ft7WI62eBeXUU2-LlKqlLsGkdo_MgkmqSgzOvVFh2_SpVm-WlSab0JLyfHLEhVDXpzsfFmw1L0zhlqwBwsnpE909J1gGcenUH_gC9FLdQXois41F0cy78xfJ8oe69v9PK6zGL9pekrL6rT7H7OOS9vr2vDxZmD7CYLDsW6UmHBslfNb6Xf2_DPM8_6dlVtw==";

    final compactJson = {
      "type": "DIDConnectReq",
      "from":
          "did:infra:01:PUB_K1_8KeFXUKBR9kctm3eafs2tgqK3XxcqsnHtRp2kjSdfDFSn3x4bK",
      "created_time": 1662441420,
      "expires_time": 1662441435,
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
        "eJwVjFsLgjAYQP_L92wXXUHtUUOCPeQFafQiukstcfMyypD99_TlwIHDmUEOpgUMXHGstBwqvPdxUoQl8csTETEtSJidG2ZbJCo5BvbZE0Qn1o_6arMuaN45l5c412g61AQ8qA3_AZ5BrRgVX95-sEteKKcf-iDRPY2N-t6OaQfOA7ZWa9MJu1FbLeyyqBZnRmvBLDjn_iP8NJc=";

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
