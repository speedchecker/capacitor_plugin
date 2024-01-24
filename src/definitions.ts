export interface SpeedCheckerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
