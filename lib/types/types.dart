/// Enum representing the compression levels for data.
///
/// The available compression levels are:
/// - `json`: Represents JSON compression.
/// - `compactJSON`: Represents compact JSON compression.
/// - `minimalCompactJSON`: Represents minimal compact JSON compression.
enum CompressionLevel { json, compactJSON, minimalCompactJSON }

enum VPRequestResponseType { submitNow, reject, submitLater }
