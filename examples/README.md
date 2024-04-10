# Examples

This repository contains examples that demonstrate the usage of the `infra-did-comm-dart` library.

## Example 1: Communication with ephmeral key

This example contains a simple demonstration of how to communicate with an ephmeral key.

1. Initialize Alice and Bob
2. Alice generate ephemeral key pair
3. Alice make JWS with alice's private key
4. Alice encrypts a message with shared key that is derived from ephemeral private key and Bob's public key
5. Bob decrypts the message with shared key that is derived from ephemeral public key and Bob's private key
6. Bob verifies the JWS with Alice's public key

```dart
dart run communicate_with_ephmeral_key.dart
```


## Example 2: Convert Ed25519 key to X25519 key

This example contains a simple demonstration of how to convert Ed25519 key to X25519 key.

```dart
dart run ed25519_to_x25519.dart
```

## Example 3: Connect to websocket server

See [example](./socket-io/README.md)