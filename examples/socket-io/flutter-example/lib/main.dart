import 'package:flutter/material.dart';
import 'package:infra_did_comm_dart/infra_did_comm_dart.dart';
import 'package:uuid/uuid.dart';

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

  void setClientWithHolderRole() {
    client = InfraDIDCommSocketClient(
      "http://data-market.test.newnal.com:9000",
      did: did,
      mnemonic: mnemonic,
      role: "HOLDER",
    );
  }

  void setClientWirhVerifierRole() {
    client = InfraDIDCommSocketClient(
      "http://data-market.test.newnal.com:9000",
      did: did,
      mnemonic: mnemonic,
      role: "VERIFIER",
    );
  }

  Future<void> connectWebsocket() async {
    client.onMessage();
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
                onPressed: setClientWirhVerifierRole,
                child: const Text("Set client Verifier Role")),
            ElevatedButton(
                onPressed: connectWebsocket, child: const Text("wsConnect")),
            ElevatedButton(
                onPressed: disconnectWebsocket,
                child: const Text("wsDisconnect")),
            ElevatedButton(
                onPressed: receiveEncodedConnectRequestMessage,
                child: const Text("Receive encoded Connect Request Message")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: connectWebsocket,
        tooltip: 'connect websocket',
        child: const Icon(Icons.connect_without_contact),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
