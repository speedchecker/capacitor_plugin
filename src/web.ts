import { Capacitor, PluginListenerHandle, Plugins, WebPlugin } from '@capacitor/core';

import { SpeedCheckerPlugin } from './definitions';
const { SpeedChecker } = Plugins;

export class SpeedCheckerWeb extends WebPlugin implements SpeedCheckerPlugin {
  private eventListeners: Map<string, PluginListenerHandle> = new Map();

  async stopTest(): Promise<void> {
    console.log('stopping test from Capacitor side');
    const handle = this.eventListeners.get('dataReceived');
        if (handle) {
            handle.remove();
            this.eventListeners.delete('dataReceived');
        }
  }

  async startTest(): Promise<void> {
    console.log('Starting test from Capacitor side');
    const handle = this.addListener('dataReceived', (data: any) => {
      console.log('Received data from Android:', data);
  });

  this.eventListeners.set('dataReceived', handle);
  }

  async setIosLicenseKey(options: { key: string }): Promise<void> {
    if (Capacitor.platform === 'ios') {
      await SpeedChecker.setIosLicenseKey(options);
      console.log('iOS license key is set to: ' + options.key);
    }
  }

  async setAndroidLicenseKey(options: { key: string }): Promise<void> {
    if (Capacitor.platform === 'android') {
      await SpeedChecker.setAndroidLicenseKey(options);
      console.log('Android license key is set to: ' + options.key);
    }
  }

  async shareBackgroundTestLogs(): Promise<void> {
    
  }

  async setBackgroundNetworkTestingEnabled(options: { bgTestingStatus: boolean }): Promise<void> {
    console.log("Background testing enabled:", options.bgTestingStatus);
  }

  async getBackgroundTestingStatus(): Promise<{ getBackgroundTestingStatus: boolean }> {
    console.log("Background Testing Status: " + this.getBackgroundTestingStatus)
    return { getBackgroundTestingStatus: false };
  }

  async setMSISDN(options: { msisdn: string }): Promise<void> {
    console.log("MSISDN: ", options.msisdn);
  }

  async setUserId(options: { userId: string }): Promise<void> {
    console.log("Uswr ID: ", options.userId);
  }
}
