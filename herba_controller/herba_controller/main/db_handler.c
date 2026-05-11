// this is the fire for storing and interating with the NVS database

#include <stdio.h>
#include "nvs_flash.h"
#include "nvs.h"
#include "esp_log.h"
#include "db_handler.h"

static const char *TAG = "DB_MODULE";



// 1. Initialize the entire NVS Partition
esp_err_t init_nvs_storage(void) {
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_LOGW(TAG, "NVS partition needs reset. Erasing...");
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    return ret;
}

/**
 * @brief Safely commits and closes an open NVS handle.
 * @param handle The handle to the NVS namespace you want to close.
 */
void close_nvs_handle(nvs_handle_t handle) {
    if (handle != 0) {
        // Always commit before closing to ensure data is written to flash
        esp_err_t err = nvs_commit(handle);
        if (err != ESP_OK) {
            ESP_LOGE(TAG, "Failed to commit NVS before closing: %s", esp_err_to_name(err));
        }
        
        nvs_close(handle);
        ESP_LOGI(TAG, "NVS handle closed safely.");
    }
}

/**
 * @brief De-initializes the entire NVS flash driver.
 * Generally used only before deep sleep or system shutdown.
 */
esp_err_t deinit_nvs_system(void) {
    return nvs_flash_deinit();
}

