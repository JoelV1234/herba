#include <string.h>
#include <stdio.h>
#include "callback.h"


void callback(message_t message) {
    char * handle = message.handle;
    char * info = message.info;
    if (strcmp(handle, (char *)"WIFI\0")==0)
    {
       printf("LIGHT ON\n");
    }
    else if (strcmp(handle, (char *)"REL_SET\0")==0)
    {
        printf("LIGHT OFF\n");
    }
    else if (strcmp(handle, (char *)"TARG_TEMP\0")==0)
    {
        printf("FAN ON\n");
    }
    else if (strcmp(handle, (char *)"SCHEDULE\0")==0)
    {
        printf("FAN OFF\n");
    }
    else if (strcmp(handle, (char *)"RESET_STATE\0")==0)
    {
        printf("FAN OFF\n");
    }
    else{
        printf("Data from the client %s\n", handle);
    }
}


