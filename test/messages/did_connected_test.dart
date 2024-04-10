import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";
import "package:uuid/uuid.dart";

void main() {
  test("Should make DID-Connected Message", () {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDConnectedMessage didConnectedMessage = DIDConnectedMessage(
      id: id,
      from: "f",
      to: ["t"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      status: "status",
    );

    expect(didConnectedMessage.id, id);
    expect(didConnectedMessage.from, "f");
    expect(didConnectedMessage.to, ["t"]);
    expect(didConnectedMessage.createdTime, currentTime);
    expect(didConnectedMessage.expiresTime, currentTime + 30000);
    expect(didConnectedMessage.context.domain, "d");
    expect(didConnectedMessage.context.action, "a");
    expect(didConnectedMessage.status, "status");
  });
}
