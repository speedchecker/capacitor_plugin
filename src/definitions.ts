export interface SpeedCheckerPlugin {

  setIosLicenseKey(options: { key: string }): Promise<void>;

  setAndroidLicenseKey(options: { key: string }): Promise<void>;

  startTest(): Promise<void>;

  stopTest(): Promise<void>;
}
