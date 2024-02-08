export interface SpeedCheckerPlugin {
    setIosLicenseKey(options: {
        key: string;
    }): Promise<void>;
    setAndroidLicenseKey(options: {
        key: string;
    }): Promise<void>;
    startTest(): Promise<void>;
    stopTest(): Promise<void>;
    shareBackgroundTestLogs(): Promise<void>;
    setBackgroundNetworkTestingEnabled(options: {
        bgTestingStatus: boolean;
    }): Promise<void>;
    getBackgroundTestingStatus(): Promise<{
        getBackgroundTestingStatus: boolean;
    }>;
    setMSISDN(options: {
        msisdn: string;
    }): Promise<void>;
    setUserId(options: {
        userId: string;
    }): Promise<void>;
}
