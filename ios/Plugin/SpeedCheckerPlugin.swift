import Foundation
import Capacitor
import SpeedcheckerSDK

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SpeedCheckerPlugin)
public class SpeedCheckerPlugin: CAPPlugin {
    private let implementation = SpeedChecker()
    
    // MARK: - Overrides
    public override func load() {
        implementation.delegate = self
    }
    
    // MARK: - Methods
    @objc public func startTest(_ call: CAPPluginCall) {
        implementation.startTest { [weak self] error in
            if let error = error {
                call.reject(error.localizedDescription, nil, error)
            } else {
                call.resolve()
                self?.sendResultDict(event: .testStarted, data: nil)
            }
        }
    }
    
    @objc public func stopTest(_ call: CAPPluginCall) {
        implementation.stopTest { error in
            if let error = error {
                call.reject(error.localizedDescription, nil, error)
            } else {
                call.resolve()
                sendResultDict(event: .testStopped, data: nil)
            }
        }
    }
    
    @objc public func shareBackgroundTestLogs(_ call: CAPPluginCall) {
        guard let viewController = self.bridge?.viewController else {
            call.reject("Missing presentation viewController")
            return
        }
        implementation.shareBackgroundTestLogs(fromViewController: viewController)
        call.resolve()
    }
    
    @objc public func setBackgroundNetworkTestingEnabled(_ call: CAPPluginCall) {
        guard let enabled = call.getBool(Key.bgTestingStatus.rawValue) else {
            call.reject("Parameter '\(Key.bgTestingStatus.rawValue)' is null")
            return
        }
        do {
            try implementation.setBackgroundTestsEnabled(enabled)
            call.resolve()
        } catch {
            call.reject(error.localizedDescription, nil, error)
        }
    }
    
    @objc public func getBackgroundTestingStatus(_ call: CAPPluginCall) {
        do {
            let enabled = try implementation.getBackgroundTestsEnabled()
            call.resolve([Key.getBackgroundTestingStatus.rawValue: enabled])
        } catch {
            call.reject(error.localizedDescription, nil, error)
        }
    }
    
    // MARK: - Helpers
    private func sendResultDict(event: SpeedTestEvent, data: [String: Any]?) {
        var resultDict = data ?? [:]
        resultDict[Key.event.rawValue] = event.rawValue
        notifyListeners(Key.dataReceivedPluginEvent.rawValue, data: resultDict)
    }
    
    private func sendErrorResult(_ error: Error) {
        let resultDict = [Key.error.rawValue: error.localizedDescription]
        notifyListeners(Key.dataReceivedPluginEvent.rawValue, data: resultDict)
    }
}

extension SpeedCheckerPlugin: SpeedCheckerDelegate {
    func speedTestFailed(error: Error) {
        sendErrorResult(error)
    }
    
    func speedTestFinished(result: SpeedTestResult) {
        sendResultDict(
            event: .testFinished,
            data: [
                Key.server.rawValue: result.server.domain ?? "",
                Key.ping.rawValue: result.latencyInMs,
                Key.jitter.rawValue: result.jitter,
                Key.downloadSpeed.rawValue: result.downloadSpeed.mbps,
                Key.uploadSpeed.rawValue: result.uploadSpeed.mbps,
                Key.connectionType.rawValue: result.connectionType ?? "",
                Key.ipAddress.rawValue: result.ipAddress ?? "",
                Key.ispName.rawValue: result.ispName ?? ""
            ]
        )
    }
    
    func speedTestPingStarted() {
        sendResultDict(event: .pingStarted, data: nil)
    }
    
    func speedTestPingFinished(serverDomain: String?, ping: Int, jitter: Int) {
        sendResultDict(
            event: .pingFinished,
            data: [
                Key.server.rawValue: serverDomain ?? "",
                Key.ping.rawValue: ping,
                Key.jitter.rawValue: jitter
            ]
        )
    }
    
    func speedTestDownloadStarted() {
        sendResultDict(event: .downloadStarted, data: nil)
    }
    
    func speedTestDownloadProgress(progress: Double, speedMbs: Double) {
        sendResultDict(
            event: .downloadProgress,
            data: [
                Key.progress.rawValue: Int(progress * 100),
                Key.downloadSpeed.rawValue: speedMbs
            ]
        )
    }
    
    func speedTestDownloadFinished() {
        sendResultDict(event: .downloadFinished, data: nil)
    }
    
    func speedTestUploadStarted() {
        sendResultDict(event: .uploadStarted, data: nil)
    }
    
    func speedTestUploadProgress(progress: Double, speedMbs: Double) {
        sendResultDict(
            event: .uploadProgress,
            data: [
                Key.progress.rawValue: Int(progress * 100),
                Key.uploadSpeed.rawValue: speedMbs
            ]
        )
    }
    
    func speedTestUploadFinished() {
        sendResultDict(event: .uploadFinished, data: nil)
    }
}

private extension SpeedCheckerPlugin {
    enum Key: String {
        case dataReceivedPluginEvent = "dataReceived"
        case iosLicenseKey
        case event
        case error
        case ping
        case jitter
        case server
        case progress
        case downloadSpeed
        case uploadSpeed
        case connectionType
        case ipAddress
        case ispName
        case bgTestingStatus
        case getBackgroundTestingStatus
    }
    
    enum SpeedTestEvent: String {
        case testStarted = "Test started"
        case pingStarted = "Ping test started"
        case pingFinished = "Ping test finished"
        case downloadStarted  = "Download test started"
        case downloadProgress = "Download test progress"
        case downloadFinished = "Download test finished"
        case uploadStarted = "Upload test started"
        case uploadProgress = "Upload test progress"
        case uploadFinished = "Upload test finished"
        case testFinished = "Test finished"
        case testStopped = "Test is stopped"
    }
}
