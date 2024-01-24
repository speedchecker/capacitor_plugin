import { registerPlugin } from '@capacitor/core';
const SpeedChecker = registerPlugin('SpeedChecker', {
    web: () => import('./web').then(m => new m.SpeedCheckerWeb()),
});
export * from './definitions';
export { SpeedChecker };
//# sourceMappingURL=index.js.map