import Foundation

/// Result of sending a push.
public typealias PushResult = Result<PushStatus, PushError>
public typealias PushResultHandler = (PushResult) -> Void

public class PushClient {
    /// Network session.
    public let session: URLSession

    /// Network connections.
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
        completion: @escaping PushResultHandler
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
    let completion: PushResultHandler

    init(certificate: URLCredential?, completion: @escaping PushResultHandler) {
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

extension ConnectionMap: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let connection = connections.removeValue(forKey: task.taskIdentifier) else {
            assertionFailure("Unknown task: \(task)"); return
        }
        let result = PushStatus.parse(
            data: connection.data,
            response: task.response,
            error: error)

        connection.completion(result)
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
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate,
           let certificate = connection.certificate {
            completionHandler(.useCredential, certificate)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
