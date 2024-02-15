#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(SpeedCheckerPlugin, "SpeedChecker",
           CAP_PLUGIN_METHOD(startTest, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stopTest, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(shareBackgroundTestLogs, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(setBackgroundNetworkTestingEnabled, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getBackgroundTestingStatus, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(removeAllListeners, CAPPluginReturnPromise);
)

