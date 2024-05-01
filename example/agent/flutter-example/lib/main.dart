import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:infra_did_comm_dart/infra_did_comm_dart.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
                      agent.disconnect();
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
        if (data.contains("..")) {
          await agent.sendDIDAuthInitMessage(data);
        } else {
          final decoded = base64.decode(data);
          final jsonString = utf8.decode(decoded);
          var decodedJson = jsonDecode(jsonString);
          var serviceEndpoint = decodedJson["serviceEndpoint"];
          var context = Context.fromJson(decodedJson["context"]);

          await agent.initWithStaticConnectRequest(serviceEndpoint, context);
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
            widget.agent.disconnect();
            Navigator.of(context).pop();
          },
          child: const Text("닫기"),
        ),
      ],
    );
  }
}
