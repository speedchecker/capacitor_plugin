'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

var core = require('@capacitor/core');

const SpeedChecker = core.registerPlugin('SpeedChecker', {
    web: () => Promise.resolve().then(function () { return web; }).then(m => new m.SpeedCheckerWeb()),
});

class SpeedCheckerWeb extends core.WebPlugin {
    async echo(options) {
        console.log('ECHO', options);
        return options;
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    SpeedCheckerWeb: SpeedCheckerWeb
});

exports.SpeedChecker = SpeedChecker;
//# sourceMappingURL=plugin.cjs.js.map
