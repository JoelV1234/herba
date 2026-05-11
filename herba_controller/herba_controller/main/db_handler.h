#include "nvs_flash.h"
#include "esp_err.h"

esp_err_t init_nvs_storage(void);
void close_nvs_handle(nvs_handle_t handle);
esp_err_t deinit_nvs_system(void);

