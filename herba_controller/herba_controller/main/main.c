#include <stdio.h>
#include "nvs_flash.h"
#include "nvs.h"
#include "db_handler.h"
#include "ble.h"

void app_main(void) {
    // 1. Initialize NVS (Required)
    init_nvs_storage();
    ble_init();
}
