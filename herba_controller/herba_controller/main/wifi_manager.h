#include "esp_err.h"

// Initialize the Wi-Fi stack (should be called once at startup)
esp_err_t wifi_manager_init(void);

// Scan for nearby networks and print them to console
void wifi_manager_scan(void);

// Connect to a specific Access Point
esp_err_t wifi_manager_connect(const char* ssid, const char* password);

// Disconnect and stop Wi-Fi
esp_err_t wifi_manager_disconnect(void);

// Returns the RSSI (signal strength) in dBm
int wifi_manager_get_rssi(void);