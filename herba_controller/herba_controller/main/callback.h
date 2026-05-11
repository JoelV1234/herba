

/**
 * data type for callback message
 */
typedef struct {
    char * handle;
    char * info;     
} message_t;

void callback(message_t message);