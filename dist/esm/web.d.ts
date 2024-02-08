import { WebPlugin } from '@capacitor/core';
import { SpeedCheckerPlugin } from './definitions';
export declare class SpeedCheckerWeb extends WebPlugin implements SpeedCheckerPlugin {
    private eventListeners;
    stopTest(): Promise<void>;
    startTest(): Promise<void>;
    setIosLicenseKey(options: {
        key: string;
    }): Promise<void>;
    setAndroidLicenseKey(options: {
        key: string;
    }): Promise<void>;
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
