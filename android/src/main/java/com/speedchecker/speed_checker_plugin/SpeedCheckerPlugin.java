package com.speedchecker.speed_checker_plugin;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.speedchecker.android.sdk.Public.EDebug;
import com.speedchecker.android.sdk.Public.SpeedTestListener;
import com.speedchecker.android.sdk.Public.SpeedTestResult;
import com.speedchecker.android.sdk.SpeedcheckerSDK;

@CapacitorPlugin(name = "SpeedChecker")
public class SpeedCheckerPlugin extends Plugin {

    private static final String PARAMETER_EVENT = "event";
    private static final String PARAMETER_ERROR = "error";
    private static final String PARAMETER_PING = "ping";
    private static final String PARAMETER_JITTER = "jitter";
    private static final String PARAMETER_DOWNLOAD_SPEED = "downloadSpeed";
    private static final String PARAMETER_UPLOAD_SPEED = "uploadSpeed";
    private static final String PARAMETER_PROGRESS = "progress";
    private static final String PARAMETER_IP = "ipAddress";
    private static final String PARAMETER_ISP = "ispName";
    private static final String PARAMETER_SERVER = "server";
    private static final String PARAMETER_CONNECTION_TYPE = "connectionType";
    private static final String GET_BACKGROUND_TESTING_STATUS = "getBackgroundTestingStatus";
    private static String LICENSE_KEY = "";

    @PluginMethod
    public void startTest(PluginCall call) {
        if(!LICENSE_KEY.isEmpty()) {
            SpeedcheckerSDK.init(getContext(), LICENSE_KEY);
            SpeedcheckerSDK.SpeedTest.setOnSpeedTestListener(new SpeedTestListener() {
                @Override
                public void onTestStarted() {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_EVENT, "Test started");
                    logResult(result, call);
                }

                @Override
                public void onFetchServerFailed(Integer errorCode) {
                    call.error("Error code: " + errorCode.toString());
                }

                @Override
                public void onFindingBestServerStarted() {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_EVENT, "Finding best server...");
                    logResult(result, call);
                }

                @Override
                public void onTestFinished(SpeedTestResult speedTestResult) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_EVENT, "Test finished");
                    result.put(PARAMETER_SERVER, speedTestResult.getServer().Domain);
                    result.put(PARAMETER_PING, speedTestResult.getPing());
                    result.put(PARAMETER_JITTER, speedTestResult.getJitter());
                    result.put(PARAMETER_DOWNLOAD_SPEED, speedTestResult.getDownloadSpeed());
                    result.put(PARAMETER_UPLOAD_SPEED, speedTestResult.getUploadSpeed());
                    result.put(PARAMETER_CONNECTION_TYPE, speedTestResult.getConnectionTypeHuman());
                    result.put(PARAMETER_IP, speedTestResult.UserIP);
                    result.put(PARAMETER_ISP, speedTestResult.UserISP);
                    logResult(result, call);
                }

                @Override
                public void onPingStarted() {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_EVENT, "Ping test started");
                    logResult(result, call);
                }

                @Override
                public void onPingFinished(int ping, int jitter) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_PING, ping);
                    result.put(PARAMETER_JITTER, jitter);
                    logResult(result, call);
                }

                @Override
                public void onDownloadTestStarted() {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_EVENT, "Download test started");
                    logResult(result, call);
                }

                @Override
                public void onDownloadTestProgress(int percent, double speedMbs, double transferredMb) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_PROGRESS, percent);
                    result.put(PARAMETER_DOWNLOAD_SPEED, speedMbs);
                    logResult(result, call);
                }

                @Override
                public void onDownloadTestFinished(double speedMbs) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_DOWNLOAD_SPEED, speedMbs);
                    logResult(result, call);
                }

                @Override
                public void onUploadTestStarted() {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_EVENT, "Upload test started");
                    logResult(result, call);
                }

                @Override
                public void onUploadTestProgress(int percent, double speedMbs, double transferredMb) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_PROGRESS, percent);
                    result.put(PARAMETER_UPLOAD_SPEED, speedMbs);
                    logResult(result, call);
                }

                @Override
                public void onUploadTestFinished(double speedMbs) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_UPLOAD_SPEED, speedMbs);
                    logResult(result, call);
                }

                @Override
                public void onTestWarning(String warning) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_ERROR, warning);
                    logResult(result, call);
                }

                @Override
                public void onTestFatalError(String error) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_ERROR, error);
                    logResult(result, call);
                }

                @Override
                public void onTestInterrupted(String error) {
                    JSObject result = new JSObject();
                    result.put(PARAMETER_ERROR, error);
                    logResult(result, call);
                }
            });
            SpeedcheckerSDK.SpeedTest.startTest(getContext());
        }
    }

    @PluginMethod
    public void stopTest(PluginCall call) {
        SpeedcheckerSDK.SpeedTest.interruptTest();
        JSObject result = new JSObject();
        result.put(PARAMETER_EVENT, "Test is stopped");
        logResult(result, call);
    }

    @PluginMethod
    public void shareBackgroundTestLogs (PluginCall call) {
        EDebug.sendLogFiles(getActivity());
    }

    @PluginMethod
    public void setBackgroundNetworkTestingEnabled (PluginCall call) {
        Boolean bgTestingStatus = call.getBoolean("bgTestingStatus");
        if (bgTestingStatus != null) {
            SpeedcheckerSDK.setBackgroundNetworkTesting(getActivity(), bgTestingStatus);
        } else {
            call.reject("Parameter 'bgTestingStatus' is null");
        }
    }
    @PluginMethod
    public void getBackgroundTestingStatus (PluginCall call) {
        boolean bgTestingStatus = SpeedcheckerSDK.isBackgroundNetworkTesting(getActivity());
        JSObject result = new JSObject();
        result.put(GET_BACKGROUND_TESTING_STATUS, bgTestingStatus);
        logResult(result, call);
    }

    @PluginMethod
    public void setMSISDN (PluginCall call) {
        String msisdn = call.getString("msisdn");
        SpeedcheckerSDK.setMSISDN(getContext(), msisdn);
    }

    @PluginMethod
    public void setUserId (PluginCall call) {
        String userId = call.getString("userId");
        SpeedcheckerSDK.setUserId(getContext(), userId);
    }

    @PluginMethod
    public void setAndroidLicenseKey(PluginCall call) {
        LICENSE_KEY = call.getString("key");
    }

    private void logResult(JSObject result, PluginCall call) {
        call.resolve(result);
        notifyListeners("dataReceived", result);
    }
}