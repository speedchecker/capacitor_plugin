import { Capacitor, Plugins, WebPlugin } from '@capacitor/core';
const { SpeedChecker } = Plugins;
export class SpeedCheckerWeb extends WebPlugin {
    constructor() {
        super(...arguments);
        this.eventListeners = new Map();
    }
    async stopTest() {
        console.log('stopping test from Capacitor side');
        const handle = this.eventListeners.get('dataReceived');
        if (handle) {
            handle.remove();
            this.eventListeners.delete('dataReceived');
        }
    }
    async startTest() {
        console.log('Starting test from Capacitor side');
        const handle = this.addListener('dataReceived', (data) => {
            console.log('Received data from Android:', data);
        });
        this.eventListeners.set('dataReceived', handle);
    }
    async setAndroidLicenseKey(options) {
        if (Capacitor.platform === 'android') {
            await SpeedChecker.setAndroidLicenseKey(options);
            console.log('Android license key is set to: ' + options.key);
        }
    }
    async shareBackgroundTestLogs() {
    }
    async setBackgroundNetworkTestingEnabled(options) {
        console.log("Background testing enabled:", options.bgTestingStatus);
    }
    async getBackgroundTestingStatus() {
        console.log("Background Testing Status: " + this.getBackgroundTestingStatus);
        return { getBackgroundTestingStatus: false };
    }
    async setMSISDN(options) {
        console.log("MSISDN: ", options.msisdn);
    }
    async setUserId(options) {
        console.log("Uswr ID: ", options.userId);
    }
}
//# sourceMappingURL=web.js.map