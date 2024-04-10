# Socket.io Example

This is an example that demonstrates how to connect to a socket.io server using this library.

## How to runs

1. Run the `flutter-example` project

```bash
cd flutter-example
flutter run
```

2. Press `Connect` button to connect to the server and get Socket ID

![ss](https://i.imgur.com/yVQEeZo.png)

3. Open `socket_io.dart` file and change the `toSocketId` to the one you got from the previous step.

```dart
  String? socketId = await client.socketId;
  if (socketId != null) {
    String toSocketId = "3C9SxnIcgKlIvN0oAAFm";
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Context context = Context(
      domain: "d",
      action: "a",
    );
    ...
  }
```

4. Run `socket_io.dart` file

```bash
dart run socket_io.dart
```