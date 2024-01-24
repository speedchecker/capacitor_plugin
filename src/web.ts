import { WebPlugin } from '@capacitor/core';

import type { SpeedCheckerPlugin } from './definitions';

export class SpeedCheckerWeb extends WebPlugin implements SpeedCheckerPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
