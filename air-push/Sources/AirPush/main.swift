import APNs
import ArgumentParser
import Chain
import Foundation
import Logging

#if Xcode
let root = #file.components(separatedBy: "/Sources")[0]
FileManager.default.changeCurrentDirectoryPath(root)
#endif

extension PushConnection: ExpressibleByArgument {}

struct AirPush: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "air-push",
        abstract: "A utility for send push notification",
        version: "0.0.1")

    @Option(help: "Specify the hexadecimal bytes of the device token for the target device.")
    var deviceToken: String

    @Option(help: "Сertificate name in the Keychain")
    var certificateName: String

    @Option(default: .development, help: "Server connection (development|production)")
    var connection: PushConnection

    @Option(help: "JSON dictionary object for your notification’s payload.")
    var body: String!

    @Option(default: "push.json", help: "The path to the file with JSON content.")
    var file: String

    @Flag(help: "Show more debugging information")
    var verbose: Bool

    mutating func run() throws {
        var logger = Logger(label: "com.air-push")
        logger.logLevel = verbose ? .debug : .info

        let certificate = try Keychain.macth(.contains(certificateName))
        logger.debug("Match certificate \"\(certificate.name)\"")

        if body == nil {
            logger.debug("Read file at path: \(file)")
            body = try String(contentsOfFile: file)
        }
        logger.debug("Body size: \(body.utf8.count)")

        let push = PushNotification(
            connection: connection,
            deviceToken: deviceToken,
            body: body)

        var outResult: PushResult!
        let client = PushClient(operationQueue: .main) // callback in main queue
        client.send(push, certificate: certificate.credential) { result in
            outResult = result
            CFRunLoopStop(CFRunLoopGetCurrent()) // stop main loop
        }
        CFRunLoopRun() // run main loop
        let status = try outResult.get()
        print(status)
    }

}

AirPush.main()
