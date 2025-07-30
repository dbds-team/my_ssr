#ifndef PROXYCHAINS_COMPAT_H
#define PROXYCHAINS_COMPAT_H

#include <netdb.h>

// Fix for 64-bit compatibility
#ifdef __LP64__
#define gethostbyaddr_compat(addr, len, type) gethostbyaddr((const void*)(addr), (socklen_t)(len), (type))
#else
#define gethostbyaddr_compat(addr, len, type) gethostbyaddr((addr), (len), (type))
#endif

#endif // PROXYCHAINS_COMPAT_H