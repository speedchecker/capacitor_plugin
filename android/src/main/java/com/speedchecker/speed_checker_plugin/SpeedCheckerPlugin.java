package com.speedchecker.speed_checker_plugin;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
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
    private static final int REQUEST_BACKGROUND_LOCATION_PERMISSION = 1;

    @PluginMethod
    public void startTest(PluginCall call) {
        SpeedcheckerSDK.init(getContext());
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
        if(!SpeedcheckerSDK.hasRequiredPermissions(getContext())) {
            Toast.makeText(getContext(), "Please grant location permission", Toast.LENGTH_SHORT).show();
            SpeedcheckerSDK.askPermissions(getActivity());
        } else if (!isLocationBackgroundPermissionGranted()) {
            Toast.makeText(getContext(), "Please grant background location permission", Toast.LENGTH_SHORT).show();
            ActivityCompat.requestPermissions(
                    getActivity(),
                    new String[]{Manifest.permission.ACCESS_BACKGROUND_LOCATION},
                    REQUEST_BACKGROUND_LOCATION_PERMISSION
            );
        } else {
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

    private void logResult(JSObject result, PluginCall call) {
        call.resolve(result);
        notifyListeners("dataReceived", result);
    }

    private boolean isLocationBackgroundPermissionGranted() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            int permissionState = ContextCompat.checkSelfPermission(getContext(), Manifest.permission.ACCESS_BACKGROUND_LOCATION);
            return permissionState == PackageManager.PERMISSION_GRANTED;
        } else {
            return true;
        }
    }
}
