import Foundation
import SpeedcheckerSDK
import CoreLocation

class SCBackgroundTestsManager: NSObject {
    private var locationManager: CLLocationManager? = CLLocationManager()
    private var backgroundTest: BackgroundTest?
    
    static let shared = SCBackgroundTestsManager()
    
    private override init() {
        super.init()
    }
    
    func setup(onAppDidFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
               licenseKey: String?,
               configURL: String?,
               testsEnabled: Bool) {
        // Init BackgroundTest
        if backgroundTest == nil {
            backgroundTest = BackgroundTest(licenseKey: licenseKey, url: configURL, testsEnabled: testsEnabled)
        }
        
        // Load your configuration
        backgroundTest?.loadConfig(launchOptions: launchOptions, completion: { success in
            // Handle case if configuration was not loaded successfully
        })
        
        // Setup location manager
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            locationManager = CLLocationManager()
        }
        locationManager?.delegate = self
        backgroundTest?.prepareLocationManager(locationManager: locationManager)
        
        // Register BGProcessingTask
        if #available(iOS 13, *) {
            backgroundTest?.registerBGTask(locationManager)
        }
    }
    
    func shareBGLogs(fromViewController viewController: UIViewController) {
        DispatchQueue.main.async {
            BackgroundTest.shareLogs(fromViewController: viewController, presentationSourceView: viewController.view)
        }
    }
    
    func getBackgroundTestsEnabled() throws -> Bool {
        guard let backgroundTest = backgroundTest else {
            throw ManagerError.backgroundTestsNotInitialized
        }
        return backgroundTest.getBackgroundNetworkTestingEnabled()
    }
    
    func setBackgroundTestsEnabled(_ enabled: Bool) throws {
        guard let backgroundTest = backgroundTest else {
            throw ManagerError.backgroundTestsNotInitialized
        }
        backgroundTest.setBackgroundNetworkTesting(testsEnabled: enabled)
    }
}

extension SCBackgroundTestsManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        backgroundTest?.didChangeAuthorization(manager: manager, status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        backgroundTest?.didUpdateLocations(manager: manager, locations: locations)
    }
}

extension SCBackgroundTestsManager {
    enum ManagerError: LocalizedError {
        case backgroundTestsNotInitialized
        
        var errorDescription: String? {
            switch self {
            case .backgroundTestsNotInitialized:
                return "Background tests are not initialized"
            }
        }
    }
}
