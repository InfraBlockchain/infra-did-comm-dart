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
  late InfraDIDCommSocketClient client;

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
    client = InfraDIDCommSocketClient(
      url: "http://data-market.test.newnal.com:9000",
      did: did,
      mnemonic: mnemonic,
      role: "HOLDER",
    );
    client.onMessage();
    client.didConnectedCallback = (String peerDID) {
      print("DID connected: $peerDID");
      setState(() {
        didConnected = true; // 연결되었음을 상태에 반영
      });
    };
  }

  void setClientWithVerifierRole() {
    client = InfraDIDCommSocketClient(
      url: "http://data-market.test.newnal.com:9000",
      did: did,
      mnemonic: mnemonic,
      role: "VERIFIER",
    );
    client.onMessage();
    client.didConnectedCallback = (String peerDID) {
      print("DID connected: $peerDID");
      setState(() {
        didConnected = true; // 연결되었음을 상태에 반영
      });
    };
  }

  Future<void> connectWebsocket() async {
    client.connect();
  }

  void disconnectWebsocket() {
    client.disconnect();
  }

  Future<void> receiveEncodedConnectRequestMessage() async {
    String? socketId = await client.socketId;
    if (socketId != null) {
      String peerSocketId = "QH0Y0ej-hx27D4DSAALY";
      final minimalCompactJson = {
        "from": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
        "body": {
          "i": {"sid": peerSocketId},
          "c": {"d": "pet-i.net", "a": "connect"},
        },
      };
      final didConnectRequestMessage =
          DIDConnectRequestMessage.fromJson(minimalCompactJson);

      String encoded = didConnectRequestMessage.encode(CompressionLevel.json);
      await client.sendDIDAuthInitMessage(encoded);
    }
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
                onPressed: receiveEncodedConnectRequestMessage,
                child: const Text("Receive encoded Connect Request Message")),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const QRCodeModal(); // 모달 창 표시
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
                client.disconnect();
                Navigator.of(context).pop(); // 모달 닫기
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> qrScanOnPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      client.disconnect();
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

    controller.scannedDataStream.listen((scanData) {
      final currentScan = DateTime.now();
      if (lastScan == null ||
          currentScan.difference(lastScan!) > const Duration(seconds: 1)) {
        lastScan = currentScan;
        String data = scanData.code!;
        print(data);
        client.sendDIDAuthInitMessage(data);
      }
    });
  }
}

class QRCodeModal extends StatefulWidget {
  const QRCodeModal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QRCodeModalState createState() => _QRCodeModalState();
}

class _QRCodeModalState extends State<QRCodeModal> {
  late InfraDIDCommSocketClient client;
  String encode = "";

  void showQR() {
    client = InfraDIDCommSocketClient(
      url: "http://data-market.test.newnal.com:9000",
      did: "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      mnemonic:
          "bamboo absorb chief dog box envelope leisure pink alone service spin more",
      role: "HOLDER",
    );
    Context context = Context(
      domain: "infra-did-comm",
      action: "connect",
    );
    makeDynamicQr(
        client,
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
            client.disconnect();
            Navigator.of(context).pop();
          },
          child: const Text("닫기"),
        ),
      ],
    );
  }
}
