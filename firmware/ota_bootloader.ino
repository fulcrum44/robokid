#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <Updater.h>

const char* AP_SSID     = "RoboKid";
const char* AP_PASSWORD = "12345678";

ESP8266WebServer otaServer(80);

void configurarOTA() {
  WiFi.mode(WIFI_AP);
  WiFi.softAPConfig(
    IPAddress(192, 168, 4, 1),
    IPAddress(192, 168, 4, 1),
    IPAddress(255, 255, 255, 0)
  );
  WiFi.softAP(AP_SSID, AP_PASSWORD);

  otaServer.on("/status", HTTP_GET, []() {
    otaServer.send(200, "application/json", "{\"status\":\"ready\"}");
  });

  otaServer.on("/update", HTTP_POST, []() {
    if (Update.hasError()) {
      otaServer.send(500, "text/plain", "ERROR");
    } else {
      otaServer.send(200, "text/plain", "OK");
      delay(500);
      ESP.restart();
    }
  }, []() {
    HTTPUpload& upload = otaServer.upload();
    if (upload.status == UPLOAD_FILE_START) {
      uint32_t maxSize = (ESP.getFreeSketchSpace() - 0x1000) & 0xFFFFF000;
      if (!Update.begin(maxSize, U_FLASH)) {
        Update.printError(Serial);
      }
    } else if (upload.status == UPLOAD_FILE_WRITE) {
      if (Update.write(upload.buf, upload.currentSize) != upload.currentSize) {
        Update.printError(Serial);
      }
    } else if (upload.status == UPLOAD_FILE_END) {
      if (!Update.end(true)) {
        Update.printError(Serial);
      }
    }
  });

  otaServer.begin();
}