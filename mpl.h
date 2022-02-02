#include <stdlib.h>
#include <string.h>

typedef struct strNODE{ 
    char*   value;
    char*   name;
    char*   data_type;
    struct strNODE*   value2;
    struct strNODE*   value3;
    struct strNODE*   value4;
}node;
