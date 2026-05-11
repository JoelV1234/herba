#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>


/**
 * Sub-struct for a simple daily schedule
 */
typedef struct {
    uint8_t start_hour;   // 0-23
    uint8_t start_minute; // 0-59
    uint8_t end_hour;
    uint8_t end_minute;
    bool is_active;       
} thermostat_schedule_t;


/**
 * Struct for configuration
 */
typedef struct {
    char * wifi_ssid;
    char * wifi_passwd;
    char * name;
} device_config_t;


/**
 * Main device state
 * Safety feature: Device will not turn on without a wifi signal.
 */
typedef struct {
    float curr_temp;
    float targ_temp;
    bool rel_state; //relay state
    thermostat_schedule_t * schedule;
    float power_usg;
    bool heater_stat;
} device_state_t;


extern device_state_t device_state;
extern device_config_t device_config;
