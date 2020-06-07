import Foundation

/// Status of sending push to APNs.
public struct PushStatus {
    /// Unexpected status.
    public static let zero = PushStatus(status: 0, id: nil)
    
    /// HTTP  status code.
    public let status: Int

    /// The apns-id value from the request.
    ///
    /// If no value was included in the request, the server creates a new UUID and returns it in this header.
    public let id: String?
}

// MARK: - Codable

extension PushStatus: Codable {
    enum CodingKeys: String, CodingKey {
        case status
        case id = "apns-id"
    }
}

// MARK: - Internal

extension PushStatus {
    init(response: HTTPURLResponse) {
        self.status = response.statusCode
        self.id = response.allHeaderFields[CodingKeys.id] as? String
    }

    static func parse(data: Data, response: URLResponse?, error: Error?) -> PushResult {
        switch (response, error) {
        case (_, let urlError as URLError):
            return .failure(.network(urlError))
        case (_, let error?):
            let urlError = URLError(.unknown, userInfo: [NSUnderlyingErrorKey: error])
            return .failure(.network(urlError))
        case (let response as HTTPURLResponse, .none) where response.statusCode == 200:
            let status = PushStatus(response: response)
            return .success(status)
        case (let response as HTTPURLResponse, .none):
            let status = PushStatus(response: response)
            let info = try? JSONDecoder().decode(PushError.UserInfo.self, from: data)
            return .failure(.status(status, info))
        case (_, .none):
            return .failure(.status(.zero, nil))
        }
    }

}
