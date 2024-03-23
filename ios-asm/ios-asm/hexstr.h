// hexstr.h

#ifndef hexstr_h
#define hexstr_h

#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif
    bool createHexStr(char *buffer, size_t len, uint64_t value);
#ifdef __cplusplus
}
#endif

#endif  // hexstr_h
