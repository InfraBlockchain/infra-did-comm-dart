# Agent Example

This is an example that demonstrates how to connect to a socket.io server using this library.

## How to runs

### Scenario 1: Holder Initiated Connection

1. Run the `agent_holder.dart` file with `initiatedByHolderScenario` function in main

```dart
main() async {
  // If you want to run the initiatedByHolderScenario, uncomment the line below
  initiatedByHolderScenario();

  // If you want to run the initiatedByVerifierScenario, uncomment the line below
  // initiatedByVerifierScenario();
}
```

```bash
dart run agent_holder.dart
```

2. Run the `agent_verifier.dart` file with `initiatedByHolderScenario` function in main 

```dart
main() async {
  // If you want to run the initiatedByHolderScenario, uncomment the line below
  initiatedByHolderScenario();

  // If you want to run the initiatedByVerifierScenario, uncomment the line below
  // initiatedByVerifierScenario();
}

...

  String? socketId = await agent.socketId;
  if (socketId != null) {
    String holderSocketId = "tDh94WFOolVYka_ZAALk"; // Set HolderSocketId
    final minimalCompactJson = {
      "from": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "body": {
        ..
        ...
      }
    }
  }
```

```bash
dart run agent_verifier.dart
```


### Scenario 2: Verifier Initiated Connection


1. Run the `agent_verifier.dart` file with `initiatedByVerifierScenario` function in main

```dart
main() async {
  // If you want to run the initiatedByHolderScenario, uncomment the line below
  // initiatedByHolderScenario();

  // If you want to run the initiatedByVerifierScenario, uncomment the line below
  initiatedByVerifierScenario();
}
```

```bash
dart run agent_verifier.dart
```

2. Run the `agent_holder.dart` file with `initiatedByVerifierScenario` function in main

```dart
main() async {
  // If you want to run the initiatedByHolderScenario, uncomment the line below
  // initiatedByHolderScenario();

  // If you want to run the initiatedByVerifierScenario, uncomment the line below
  initiatedByVerifierScenario();
}

...

  String? socketId = await agent.socketId;
  if (socketId != null) {
    String verifierSocketId = "G_A98d1uN5zwvLBzAALq"; // Set VerifierSocketId
    final minimalCompactJson = {
      "from": "did:infra:01:5EX1sTeRrA7nwpFmapyUhMhzJULJSs9uByxHTc6YTAxsc58z",
      "body": {
        "i": {"sid": verifierSocketId},
        "c": {"d": "pet-i.net", "a": "connect"},
      },
    };
  }

```

```bash
dart run agent_holder.dart
```