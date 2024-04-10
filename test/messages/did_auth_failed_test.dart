import "package:infra_did_comm_dart/infra_did_comm_dart.dart";
import "package:test/test.dart";
import "package:uuid/uuid.dart";

void main() {
  test("Should make DID-Auth-Failed Message", () {
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    var uuid = Uuid();
    var id = uuid.v4();
    DIDAuthFailedMessage didAuthFailedMessage = DIDAuthFailedMessage(
      id: id,
      from: "f",
      to: ["t"],
      createdTime: currentTime,
      expiresTime: currentTime + 30000,
      context: context,
      reason: "reason",
    );

    expect(didAuthFailedMessage.id, id);
    expect(didAuthFailedMessage.from, "f");
    expect(didAuthFailedMessage.to, ["t"]);
    expect(didAuthFailedMessage.createdTime, currentTime);
    expect(didAuthFailedMessage.expiresTime, currentTime + 30000);
    expect(didAuthFailedMessage.context.domain, "d");
    expect(didAuthFailedMessage.context.action, "a");
    expect(didAuthFailedMessage.reason, "reason");
  });
}
