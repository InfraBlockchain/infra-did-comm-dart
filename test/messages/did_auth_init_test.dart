import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";
import "package:uuid/uuid.dart";

void main() {
  test("Should make DID-Auth-Init Message", () {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthInitMessage didAuthInitMessage = DIDAuthInitMessage(
      id: id,
      from: "f",
      to: ["t"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      socketId: "socketId",
      peerSocketId: "peerSocketId",
    );

    expect(didAuthInitMessage.id, id);
    expect(didAuthInitMessage.from, "f");
    expect(didAuthInitMessage.to, ["t"]);
    expect(didAuthInitMessage.createdTime, currentTime);
    expect(didAuthInitMessage.expiresTime, currentTime + 30000);
    expect(didAuthInitMessage.context.domain, "d");
    expect(didAuthInitMessage.context.action, "a");
    expect(didAuthInitMessage.socketId, "socketId");
    expect(didAuthInitMessage.peerSocketId, "peerSocketId");
  });
}
