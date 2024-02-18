import Foundation
import SpeedcheckerSDK

protocol SpeedCheckerDelegate: AnyObject {
    func speedTestFailed(error: Error)
    func speedTestFinished(result: SpeedTestResult)
    func speedTestPingStarted()
    func speedTestPingFinished(serverDomain: String?, ping: Int, jitter: Int)
    func speedTestDownloadStarted()
    func speedTestDownloadProgress(progress: Double, speedMbs: Double)
    func speedTestDownloadFinished()
    func speedTestUploadStarted()
    func speedTestUploadProgress(progress: Double, speedMbs: Double)
    func speedTestUploadFinished()
}

@objc public class SpeedChecker: NSObject {
    private var internetSpeedTest: InternetSpeedTest?
    
    private static var licenseKey: String? {
        return Bundle.main.infoDictionary?[PlistKey.licenseKey.rawValue] as? String
    }
    private static var bgConfigURL: String? {
        return Bundle.main.infoDictionary?[PlistKey.configURL.rawValue] as? String
    }
    
    weak var delegate: SpeedCheckerDelegate?
    
    // MARK: - Methods
    
    func startTest(completion: @escaping (_ error: Error?) -> Void) {
        let licenseKey = Self.licenseKey
        internetSpeedTest = InternetSpeedTest(licenseKey: licenseKey, delegate: self)
        
        let onTestStart: (SpeedcheckerSDK.SpeedTestError) -> Void = { (error) in
            completion(error != .ok ? error : nil)
        }
        
        if (licenseKey ?? "").isEmpty {
            internetSpeedTest?.startFreeTest(onTestStart)
        } else {
            internetSpeedTest?.start(onTestStart)
        }
    }
    
    func stopTest(completion: (_ error: Error?) -> Void) {
        guard let internetSpeedTest = internetSpeedTest else {
            completion(nil)
            return
        }
        
        internetSpeedTest.forceFinish { error in
            completion(error != .ok ? error : nil)
        }
    }
    
    /// Initialize background tests.
    /// - Parameters:
    ///   - launchOptions: Dictionary with app launch options
    ///   - testsEnabled: Bool value which tells if tests are enabled on init
    @objc public static func initializeBackgroundTests(launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                                       testsEnabled: Bool = true) {
        SCBackgroundTestsManager.shared.setup(onAppDidFinishLaunchingWithOptions: launchOptions,
                                              licenseKey: licenseKey,
                                              configURL: bgConfigURL,
                                              testsEnabled: testsEnabled)
    }
    
    func shareBackgroundTestLogs(fromViewController viewController: UIViewController) {
        SCBackgroundTestsManager.shared.shareBGLogs(fromViewController: viewController)
    }
    
    func getBackgroundTestsEnabled() throws -> Bool {
        return try SCBackgroundTestsManager.shared.getBackgroundTestsEnabled()
    }
    
    func setBackgroundTestsEnabled(_ enabled: Bool) throws {
        try SCBackgroundTestsManager.shared.setBackgroundTestsEnabled(enabled)
    }
}

extension SpeedChecker: InternetSpeedTestDelegate {
    public func internetTestError(error: SpeedcheckerSDK.SpeedTestError) {
        delegate?.speedTestFailed(error: error)
    }
    
    public func internetTestFinish(result: SpeedcheckerSDK.SpeedTestResult) {
        delegate?.speedTestFinished(result: result)
    }
    
    public func internetTestReceived(servers: [SpeedcheckerSDK.SpeedTestServer]) {
        guard !servers.isEmpty else {
            return
        }
        delegate?.speedTestPingStarted()
    }
    
    public func internetTestSelected(server: SpeedcheckerSDK.SpeedTestServer, latency: Int, jitter: Int) {
        delegate?.speedTestPingFinished(serverDomain: server.domain, ping: latency, jitter: jitter)
    }
    
    public func internetTestDownloadStart() {
        delegate?.speedTestDownloadStarted()
    }
    
    public func internetTestDownloadFinish() {
        delegate?.speedTestDownloadFinished()
    }
    
    public func internetTestDownload(progress: Double, speed: SpeedcheckerSDK.SpeedTestSpeed) {
        delegate?.speedTestDownloadProgress(progress: progress, speedMbs: speed.mbps)
    }
    
    public func internetTestUploadStart() {
        delegate?.speedTestUploadStarted()
    }
    
    public func internetTestUploadFinish() {
        delegate?.speedTestUploadFinished()
    }
    
    public func internetTestUpload(progress: Double, speed: SpeedcheckerSDK.SpeedTestSpeed) {
        delegate?.speedTestUploadProgress(progress: progress, speedMbs: speed.mbps)
    }
}

extension SpeedTestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .ok:
            return "Ok"
        case .invalidSettings:
            return "Invalid settings"
        case .invalidServers:
            return "Invalid servers"
        case .inProgress:
            return "In progress"
        case .failed:
            return "Failed"
        case .notSaved:
            return "Not saved"
        case .cancelled:
            return "Cancelled"
        case .locationUndefined:
            return "Location undefined"
        case .appISPMismatch:
            return "App-ISP mismatch"
        case .invalidlicenseKey:
            return "Invalid license key"
        @unknown default:
            return "Unknown"
        }
    }
}

private extension SpeedChecker {
    enum PlistKey: String {
        case licenseKey = "SpeedCheckerLicenseKey"
        case configURL = "SpeedCheckerBackgroundConfigURL"
    }
}
