export interface SpeedCheckerPlugin {

  setAndroidLicenseKey(options: { key: string }): Promise<void>;

  startTest(): Promise<void>;

  stopTest(): Promise<void>;
}
