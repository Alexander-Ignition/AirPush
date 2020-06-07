import Foundation

public struct PushNotification {
    /// APNs Connections. Default `.development`.
    public var connection: PushConnection

    /// The hexadecimal bytes of the device token for the target device.
    public var deviceToken: String

    /// APNs request headers. Default empty.
    public var headers = Headers()

    /// The body content of your message is the JSON dictionary object for your notification’s payload.
    /// The body data must not be compressed and its maximum size is 4KB (4096 bytes).
    /// For a Voice over Internet Protocol (VoIP) notification, the body data maximum size is 5KB (5120 bytes).
    public var body: String

    /// APNs request headers.
    public struct Headers {
        /// The provider token that authorizes APNs to send push notifications for the specified topics.
        /// The token is in Base64URL-encoded JWT format, specified as bearer <provider token>.
        /// When the provider certificate is used to establish a connection, this request header is ignored.
        public var authorization: String?

        /// A canonical UUID that identifies the notification. If there is an error sending the notification,
        /// APNs uses this value to identify the notification to your server. If you omit this header,
        /// a new UUID is created by APNs and returned in the response.
        public var id: UUID?

        /// A UNIX epoch date expressed in seconds (UTC). This header identifies the date when
        /// the notification is no longer valid and can be discarded.
        public var expiration: Int?

        /// The priority of the notification.
        ///
        ///  * 10 – Send the push message immediately.
        ///  * 5 – Send the push message at a time that takes into account power considerations for the device.
        ///
        /// If you omit this header, the APNs server sets the priority to 10.
        public var priority: Int?

        /// The topic of the remote notification, which is typically the bundle ID for your app.
        public var topic: String?

        /// Multiple notifications with the same collapse identifier are displayed to the user as a single notification.
        public var collapseId: String?

        /// A new empty `Headers`.
        public init() {}
    }

    public init(
        connection: PushConnection = .development,
        deviceToken: String,
        headers: Headers = Headers(),
        body: String
    ) {
        self.connection = connection
        self.deviceToken = deviceToken
        self.headers = headers
        self.body = body
    }

    public var pushDescription: String {
        var map = KeyMap<CodingKeys>()
        map[.connection] = connection
        map[.deviceToken] = deviceToken
        map[.body] = body
        return map.string
    }
}

struct KeyMap<Key> where Key: RawRepresentable, Key.RawValue == String {
    private var fields: [String] = []

    var string: String { fields.joined(separator: "\n") }

    subscript<T>(field: Key) -> T? {
        get {
            fatalError()
        }
        set {
            if let value = newValue {
                fields.append("\(field.rawValue): \(value)")
            }
        }
    }
}

// MARK: - Codable

extension PushNotification.Headers: Codable {
    enum CodingKeys: String, CodingKey {
        case authorization
        case id = "apns-id"
        case expiration = "apns-expiration"
        case priority = "apns-priority"
        case topic = "apns-topic"
        case collapseId = "apns-collapse-id"
    }
}

extension PushNotification: Codable {
    enum CodingKeys: String, CodingKey {
        case connection
        case deviceToken = "device-token"
        case headers
        case body
    }
}

// MARK: - Request

extension PushNotification.Headers {
    fileprivate var dictionary: [CodingKeys: String] {
        var headers: [CodingKeys: String] = [:]
        headers[.authorization] = authorization.map { "bearer \($0)" }
        headers[.id] = id?.uuidString
        headers[.expiration] = expiration.map { String($0) }
        headers[.priority] = priority.map { String($0) }
        headers[.topic] = topic
        headers[.collapseId] = collapseId
        return headers
    }
}

extension PushNotification {
    var request: URLRequest {
        let url = connection.url.appendingPathComponent("/3/device/\(deviceToken)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.dictionary.forEach { request.setValue($1, forHTTPHeaderField: $0.rawValue) }
        request.httpBody = Data(body.utf8)
        return request
    }
}
