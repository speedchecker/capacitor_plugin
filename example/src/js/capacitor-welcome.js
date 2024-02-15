import { SpeedChecker} from '@speedchecker/capacitor-plugin'

window.customElements.define(
  'capacitor-welcome',
  class extends HTMLElement {
    constructor() {
      super();

      const root = this.attachShadow({ mode: 'open' });

      root.innerHTML = `
    <style>
      :host {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        display: block;
        width: 100%;
        height: 100%;
      }
      .button {
        display: inline-block;
        padding: 10px;
        background-color: #73B5F6;
        color: #fff;
        font-size: 0.9em;
        border: 0;
        border-radius: 3px;
        text-decoration: none;
        cursor: pointer;
        margin-right: 10px;
      }
      main {
        padding: 15px;
        text-align: center;
      }
      main p {
        color: #333;
      }
      main pre {
        white-space: pre-line;
      }
    </style>
    <div>
      <capacitor-welcome-titlebar>
        <h1>Capacitor</h1>
      </capacitor-welcome-titlebar>
      <main>
        <p>
        Capacitor sample app with Speedcheker plugin. 
        </p>
        <p>
          <button class="button" id="startTestBtn">Start Test</button>
          <button class="button" id="stopTestBtn">Stop Test</button>
        </p>
        <div id="log"></div>
      </main>
    </div>
    `;
    }

    connectedCallback() {
      const self = this;
      const logDiv = self.shadowRoot.getElementById('log');

      // SpeedChecker.setAndroidLicenseKey({ key: '_your_android_key' });

      self.shadowRoot.querySelector('#startTestBtn').addEventListener('click', async function (e) {
        try {
            await SpeedChecker.addListener('dataReceived', (data) => {
              const event = data.event;
              const ping = data.ping;
              const progress = data.progress;
              const downloadSpeed = data.downloadSpeed;
              const uploadSpeed = data.uploadSpeed;
              const error = data.error;
              let logText = '';
      
              if (event) {
                logText = event;
              }
      
              if (ping) {
                logText = 'Ping: ' + ping.toFixed() + ' ms';
              }

              if (progress && downloadSpeed) {
                logText = 'Progress: ' + progress + '%<br>Download speed: ' + downloadSpeed.toFixed(2) + ' Mbps';
              }

              if (progress && uploadSpeed) {
                logText = 'Progress: ' + progress + '%<br>Upload speed: ' + uploadSpeed.toFixed(2) + ' Mbps';
              }
      
              if (event == 'Test finished') {
                logText = 'Test finished <br>Ping: ' + ping +  '<br>Download speed: ' + downloadSpeed.toFixed(2) + ' Mbps' + '<br>Upload speed: ' + uploadSpeed.toFixed(2) + ' Mbps<br> Jitter: ' + data.jitter + '<br>ConnectionType: ' + data.connectionType + '<br>Server: ' + data.server + '<br>Ip: ' + data.ipAddress + '<br>Isp: ' + data.ispName;
                console.log(logText);
      
                SpeedChecker.removeAllListeners();
              } else if (error) {
                logText = error;

                SpeedChecker.removeAllListeners();
              }
      
              logDiv.innerHTML = logText;
            });
      
          await SpeedChecker.startTest();
        } catch (error) {
          console.error(error);
          logDiv.innerHTML = error;
          SpeedChecker.removeAllListeners();
        }
      });
      
      self.shadowRoot.querySelector('#stopTestBtn').addEventListener('click', async function (e) {
        try {
          await SpeedChecker.stopTest();
          SpeedChecker.removeAllListeners();
        } catch (error) {
          console.error(error);
          logDiv.innerHTML = error;
        }
      });
           
    }    
  }
);

window.customElements.define(
  'capacitor-welcome-titlebar',
  class extends HTMLElement {
    constructor() {
      super();
      const root = this.attachShadow({ mode: 'open' });
      root.innerHTML = `
    <style>
      :host {
        position: relative;
        display: block;
        padding: 15px 15px 15px 15px;
        text-align: center;
        background-color: #73B5F6;
      }
      ::slotted(h1) {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        font-size: 0.9em;
        font-weight: 600;
        color: #fff;
      }
    </style>
    <slot></slot>
    `;
    }
  }
);
