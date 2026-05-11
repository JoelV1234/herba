#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_wifi.h"
#include "esp_log.h"
#include "wifi_manager.h"

static const char *TAG = "WIFI_MGR";

// Initialize Wi-Fi but don't connect yet
esp_err_t wifi_manager_init(void) {
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    esp_netif_create_default_wifi_sta();

    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    return esp_wifi_start();
}

// Scan for available APs
void wifi_manager_scan(void) {
    uint16_t number = 10; // Max number of APs to find
    wifi_ap_record_t ap_info[10];
    uint16_t ap_count = 0;

    esp_wifi_scan_start(NULL, true);
    esp_wifi_scan_get_ap_records(&number, ap_info);
    esp_wifi_scan_get_ap_num(&ap_count);

    ESP_LOGI(TAG, "Found %d networks:", ap_count);
    for (int i = 0; i < ap_count; i++) {
        ESP_LOGI(TAG, "SSID: %s | RSSI: %d", ap_info[i].ssid, ap_info[i].rssi);
    }
}

// Connect to an AP
esp_err_t wifi_manager_connect(const char* ssid, const char* password) {
    wifi_config_t wifi_config = {0};
    strncpy((char*)wifi_config.sta.ssid, ssid, sizeof(wifi_config.sta.ssid));
    strncpy((char*)wifi_config.sta.password, password, sizeof(wifi_config.sta.password));

    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_STA, &wifi_config));
    return esp_wifi_connect();
}

// Disconnect
esp_err_t wifi_manager_disconnect(void) {
    return esp_wifi_disconnect();
}

// Get Signal Strength (RSSI)
int wifi_manager_get_rssi(void) {
    wifi_ap_record_t ap;
    if (esp_wifi_sta_get_ap_info(&ap) == ESP_OK) {
        return ap.rssi;
    }
    return -127; // Error/Not connected
}