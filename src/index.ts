import { registerPlugin } from '@capacitor/core';

import type { SpeedCheckerPlugin } from './definitions';

const SpeedChecker = registerPlugin<SpeedCheckerPlugin>('SpeedChecker', {
  web: () => import('./web').then(m => new m.SpeedCheckerWeb()),
});

export * from './definitions';
export { SpeedChecker };
