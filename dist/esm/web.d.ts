import { WebPlugin } from '@capacitor/core';
import type { SpeedCheckerPlugin } from './definitions';
export declare class SpeedCheckerWeb extends WebPlugin implements SpeedCheckerPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
