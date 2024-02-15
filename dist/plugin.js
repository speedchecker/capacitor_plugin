var capacitorSpeedChecker = (function (exports, core) {
    'use strict';

    const SpeedChecker$1 = core.registerPlugin('SpeedChecker', {
        web: () => Promise.resolve().then(function () { return web; }).then(m => new m.SpeedCheckerWeb()),
    });

    const { SpeedChecker } = core.Plugins;
    class SpeedCheckerWeb extends core.WebPlugin {
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
            if (core.Capacitor.platform === 'android') {
                await SpeedChecker.setAndroidLicenseKey(options);
                console.log('Android license key is set to: ' + options.key);
            }
        }
    }

    var web = /*#__PURE__*/Object.freeze({
        __proto__: null,
        SpeedCheckerWeb: SpeedCheckerWeb
    });

    exports.SpeedChecker = SpeedChecker$1;

    Object.defineProperty(exports, '__esModule', { value: true });

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
