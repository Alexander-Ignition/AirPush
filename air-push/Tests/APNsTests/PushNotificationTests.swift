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
        push.headers.collapseId = "group-10"

        // When
        let request = push.request

        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.scheme, "https")
        XCTAssertEqual(request.url?.host, "api.push.apple.com")
        XCTAssertEqual(request.url?.path, "/3/device/device-token-3")
        XCTAssertEqual(request.allHTTPHeaderFields?.count, 6)
        XCTAssertEqual(request.allHTTPHeaderFields, [:])
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "authorization"), "jwt")
        XCTAssertEqual(request.value(forHTTPHeaderField: "id"), id.uuidString)
        XCTAssertEqual(request.value(forHTTPHeaderField: "expiration"), "\(timestamp)")
        XCTAssertEqual(request.value(forHTTPHeaderField: "collapseId"), "group-10")
        XCTAssertEqual(request.httpBody, Data("push-3".utf8))
    }
}
