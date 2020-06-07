import Foundation

public typealias CompletionHandler = (Result<(Data, URLResponse?), Error>) -> Void

public class PushClient {
    public let session: URLSession
    private let connectionMap = ConnectionMap()

    public init(
        configuration: URLSessionConfiguration = .ephemeral,
        operationQueue: OperationQueue? = nil
    ) {
        if let queue = operationQueue {
            precondition(queue.maxConcurrentOperationCount == 1)
        }
        self.session = URLSession(
            configuration: configuration,
            delegate: connectionMap,
            delegateQueue: operationQueue)
        self.session.sessionDescription = "com.air-push.apns.network.session"
    }

    @discardableResult
    public func send(
        _ notification: PushNotification,
        certificate: URLCredential?,
        completion: @escaping CompletionHandler
    ) -> URLSessionTask {

        let task = session.dataTask(with: notification.request)
        let connection = TaskConnection(certificate: certificate, completion: completion)
        session.delegateQueue.addOperation { [connectionMap] in
            connectionMap.connections[task.taskIdentifier] = connection
        }
        task.resume()
        return task
    }
}

final class TaskConnection {
    var data = Data()
    let certificate: URLCredential?
    let completion: CompletionHandler

    init(certificate: URLCredential?, completion: @escaping CompletionHandler) {
        self.certificate = certificate
        self.completion = completion
    }
}

final class ConnectionMap: NSObject {
    var connections: [Int: TaskConnection] = [:]
}

// MARK: - URLSessionDataDelegate

extension ConnectionMap: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        connections[dataTask.taskIdentifier]?.data.append(data)
    }
}

// MARK: - URLSessionTaskDelegate

struct ResponseError: Error, Codable {
    let reason: String
    let timestamp: Int?
}

struct PushStatus {
    /// HTTP  status code.
    let status: Int

    /// Push notification id.
    let id: String?
}

enum PushError: Error {
    /// Respone with error.
    case status(PushStatus, ResponseError)

    /// Network error.
    case network(URLError)

    // Unknown error.
    case unknown(Error)
}

typealias RushResult = Result<PushStatus, PushError>

extension ConnectionMap: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let connection = connections.removeValue(forKey: task.taskIdentifier) else {
            assertionFailure("Unknown task: \(task)"); return
        }
        if let error = error {
            connection.completion(.failure(error))
        } else {
            let value = (connection.data, task.response)
            connection.completion(.success(value))
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard let connection = connections[task.taskIdentifier] else {
            assertionFailure("Unknown task: \(task)"); return
        }
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            completionHandler(.useCredential, connection.certificate)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
