@testable import APNs
import XCTest

final class PushNotificationTests: XCTestCase {
    func testDevelopmentRequest() {
        // Given
        let push = PushNotification(
            connection: .development,
            deviceToken: "device-token-1",
            body: "push-1"
        )
        // When
        let request = push.request

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "api.development.push.apple.com")
        XCTAssertEqual(request.url?.path, "/3/device/device-token-1")
        XCTAssertEqual(request.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(request.httpBody, Data("push-1".utf8))
    }

    func testProductionRequest() {
        // Given
        let push = PushNotification(
            connection: .production,
            deviceToken: "device-token-2",
            body: "push-2"
        )
        // When
        let request = push.request

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "api.push.apple.com")
        XCTAssertEqual(request.url?.path, "/3/device/device-token-2")
        XCTAssertEqual(request.allHTTPHeaderFields, ["Content-Type": "application/json"])
        XCTAssertEqual(request.httpBody, Data("push-2".utf8))
    }

    func testRequestWithHeaders() {
        // Given
        let timestamp = Int(Date().timeIntervalSince1970)
        let id = UUID()

        var push = PushNotification(
            connection: .production,
            deviceToken: "device-token-3",
            body: "push-3"
        )
        push.headers.authorization = "jwt"
        push.headers.id = id
        push.headers.expiration = timestamp
        push.headers.priority = 10
        push.headers.topic = "com.example.app"
        push.headers.collapseId = "group-10"

        // When
        let request = push.request

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "api.push.apple.com")
        XCTAssertEqual(request.url?.path, "/3/device/device-token-3")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 7)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "authorization"), "bearer jwt")
        XCTAssertEqual(request.value(forHTTPHeaderField: "apns-id"), id.uuidString)
        XCTAssertEqual(request.value(forHTTPHeaderField: "apns-priority"), "10")
        XCTAssertEqual(request.value(forHTTPHeaderField: "apns-topic"), "com.example.app")
        XCTAssertEqual(request.value(forHTTPHeaderField: "apns-expiration"), "\(timestamp)")
        XCTAssertEqual(request.value(forHTTPHeaderField: "apns-collapse-id"), "group-10")
        XCTAssertEqual(request.httpBody, Data("push-3".utf8))
    }
}
