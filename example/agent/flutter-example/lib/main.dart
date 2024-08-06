import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infra_did_comm_dart/infra_did_comm_dart.dart';
import 'package:infra_did_dart/infra_did_dart.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<Map<String, dynamic>> vpRejectCallback(
    List<RequestVC> requestVCs, String challenge) {
  // If want to reject the request, return the following JSON
  return Future.value({
    "status": "reject",
    "reason": "I don't have the requested VC",
  });
}

Future<Map<String, dynamic>> vpSubmitLaterCallback(
    List<RequestVC> requestVCs, String challenge) {
  // If want to submit later the requested VCs, return the following JSON
  return Future.value({"status": "submitLater"});
}

Future<Map<String, dynamic>> vpSubmitCallback(
    List<RequestVC> requestVCs, String challenge) async {
  String phrase =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  InfraSS58DIDSet didSet =
      await InfraSS58DID.generateSS58DIDFromPhrase(phrase, "01");

  InfraSS58DID infraSS58DID = InfraSS58DID(
    didSet: didSet,
    chainEndpoint: "wss://did.stage.infrablockspace.net",
    controllerDID: didSet.did,
    controllerMnemonic: didSet.mnemonic,
  );

  String unsignedVP = """
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://www.w3.org/2018/credentials/examples/v1",
    "https://schema.org"
  ],
  "verifiableCredential": [
    {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://schema.org"
      ],
      "id": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "type": [
        "VerifiableCredential"
      ],
      "credentialSubject": [
        {
          "id": "did:example:d23dd687a7dc6787646f2eb98d0"
        }
      ],
      "issuanceDate": "2024-05-23T06:08:03.039Z",
      "issuer": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "proof": {
        "type": "Ed25519Signature2018",
        "proofPurpose": "assertionMethod",
        "verificationMethod": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z#keys-1",
        "created": "2024-06-05T07:44:22.102309Z",
        "proofValue": "zDsXfPU4MyohXEATJSYUuVehhRsjc8dShBEmTx7oEgJaqzCzEHz3SgwEyRKDtxegifHhKtY3wBwL2z9H2Rt5jv2h"
      }
    }
  ],
  "id": "http://example.edu/credentials/2803",
  "type": [
    "VerifiablePresentation",
    "CredentialManagerPresentation"
  ],
  "holder": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z"
}
    """;
  CredentialSigner cs = CredentialSigner(
    did: didSet.did,
    keyId: "keys-1",
    keyType: "Ed25519VerificationKey2018",
    seed: didSet.seed,
    mnemonic: didSet.mnemonic,
  );

  final vp = await InfraSS58VerifiablePresentation().issueVp(
      jsonDecode(unsignedVP), infraSS58DID.didSet.did, cs,
      domain: "newnal", challenge: challenge, purpose: "authentication");

  return {
    "status": "submit",
    "vp": jsonEncode(vp),
  };
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'infra-did-comm-dart example app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String mnemonic =
      "bamboo absorb chief dog box envelope leisure pink alone service spin more";
  String did = "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z";
  late InfraDIDCommAgent agent = InfraDIDCommAgent(
    url: "http://data-market.test.newnal.com:9000",
    did: did,
    mnemonic: mnemonic,
    role: "HOLDER",
  );
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  DateTime? lastScan;
  bool didConnected = false; // 연결 여부를 나타내는 상태 변수

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void setClientWithHolderRole() {
    agent.changeRole("HOLDER");
    agent.setDIDConnectedCallback((peerDID) => {
          print("DID connected1: $peerDID"),
          setState(() {
            didConnected = true; // 연결되었음을 상태에 반영
          })
        });
  }

  void setClientWithVerifierRole() {
    agent.changeRole("VERIFIER");
    agent.setDIDConnectedCallback((peerDID) => {
          print("DID connected2: $peerDID"),
          setState(() {
            didConnected = true; // 연결되었음을 상태에 반영
          })
        });
  }

  Future<void> connectWebsocket() async {
    agent.connect();
  }

  void disconnectWebsocket() {
    agent.disconnect();
  }

  void setVPSubmitCallback() {
    agent.setVPRequestCallback(vpSubmitCallback);
  }

  void setVPSubmitLaterCallback() {
    agent.setVPRequestCallback(vpSubmitLaterCallback);
  }

  void setVPRejectCallback() {
    agent.setVPRequestCallback(vpRejectCallback);
  }

  Future<void> sendVPReq() async {
    if (!agent.isDIDConnected) {
      print("DID is not connected");
      return;
    }
    List<RequestVC> requestVCs = [RequestVC(vcType: "test")];
    agent.sendVPReq(requestVCs, "challenge");
  }

  @override
  Widget build(BuildContext context) {
    if (didConnected) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showModal(context);
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: setClientWithHolderRole,
                child: const Text("Set client Holder Role")),
            ElevatedButton(
                onPressed: setClientWithVerifierRole,
                child: const Text("Set client Verifier Role")),
            ElevatedButton(
                onPressed: connectWebsocket, child: const Text("wsConnect")),
            ElevatedButton(
                onPressed: disconnectWebsocket,
                child: const Text("wsDisconnect")),
            ElevatedButton(
                onPressed: setVPRejectCallback,
                child: const Text("Set VP Reject Callback")),
            ElevatedButton(
                onPressed: setVPSubmitCallback,
                child: const Text("Set VP Submit Callback")),
            ElevatedButton(
                onPressed: setVPSubmitLaterCallback,
                child: const Text("Set VP Submit Later Callback")),
            ElevatedButton(
                onPressed: sendVPReq,
                child: const Text("Send VP Request Message")),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return QRCodeModal(agent: agent); // 모달 창 표시
                  },
                );
              },
              child: const Text("Show QR Code"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'QR code scan',
        onPressed: () async {
          await qrScanOnPressed();
        },
        child: const Icon(Icons.qr_code_scanner),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("DID Connected"),
          content: Text("DID connected successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> qrScanOnPressed() async {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: scanArea),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.pop(context); // 뒤로가기 버튼
                    },
                    tooltip: '뒤로가기',
                    child: Icon(Icons.arrow_back),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    agent.disconnect();
    agent.connect();
    controller.scannedDataStream.listen((scanData) async {
      final currentScan = DateTime.now();
      if (lastScan == null ||
          currentScan.difference(lastScan!) > const Duration(seconds: 3)) {
        lastScan = currentScan;
        String data = scanData.code!;
        print("Scanned data: $data");
        final decoded = base64.decode(data);
        final jsonString = utf8.decode(decoded);
        Map<String, dynamic> decodedJson = jsonDecode(jsonString);
        if (decodedJson.containsKey("from")) {
          await agent.sendDIDAuthInitMessage(data);
        } else {
          var serviceEndpoint = decodedJson["serviceEndpoint"];
          var context = Context.fromJson(decodedJson["context"]);
          await agent.initReceivingStaticConnectRequest(
              serviceEndpoint, context);
        }
      }
    });
  }
}

class QRCodeModal extends StatefulWidget {
  final InfraDIDCommAgent agent;

  const QRCodeModal({Key? key, required this.agent}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _QRCodeModalState createState() => _QRCodeModalState();
}

class _QRCodeModalState extends State<QRCodeModal> {
  String encode = "";

  void showQR() {
    Context context = Context(
      domain: "infra-did-comm",
      action: "connect",
    );
    didConnectRequestLoop(
        widget.agent,
        context,
        15,
        (encodedMessage) => {
              setState(() {
                encode = encodedMessage;
              })
            });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("QR Code"),
      content: Container(
          height: 320,
          width: 320,
          child: encode == ""
              ? const Text("")
              : QrImageView(
                  data: encode,
                  version: QrVersions.auto,
                  size: 320,
                  gapless: false,
                )),
      actions: [
        ElevatedButton(
          onPressed: () {
            showQR();
          },
          child: const Text("QR Code generate"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("닫기"),
        ),
      ],
    );
  }
}
