import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";
import "package:uuid/uuid.dart";

void main() {
  test("Should make DID-Auth Message", () {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthMessage didAuthMessage = DIDAuthMessage(
      id: id,
      from: "f",
      to: ["t"],
      createdTime: currentTime,
      expiresTime: currentTime + 1000,
      context: context,
      socketId: "socketId",
      peerSocketId: "peerSocketId",
    );

    expect(didAuthMessage.id, id);
    expect(didAuthMessage.from, "f");
    expect(didAuthMessage.to, ["t"]);
    expect(didAuthMessage.createdTime, currentTime);
    expect(didAuthMessage.expiresTime, currentTime + 1000);
    expect(didAuthMessage.context.domain, "d");
    expect(didAuthMessage.context.action, "a");
    expect(didAuthMessage.socketId, "socketId");
    expect(didAuthMessage.peerSocketId, "peerSocketId");
  });
}
