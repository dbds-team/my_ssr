#!/bin/bash

# Fix proxychains for 64-bit compilation
echo "Fixing proxychains for 64-bit compilation..."

# Create a patch for libproxychains.c if the source exists
PROXYCHAINS_SRC="proxychains/src/libproxychains.c"
if [ -f "$PROXYCHAINS_SRC" ]; then
    echo "Patching $PROXYCHAINS_SRC for 64-bit compatibility..."
    
    # Backup original file
    cp "$PROXYCHAINS_SRC" "$PROXYCHAINS_SRC.bak"
    
    # Replace the problematic gethostbyaddr declaration
    sed -i 's/struct hostent \*gethostbyaddr(const char \*addr, int len, int type)/struct hostent *gethostbyaddr_compat(const void *addr, socklen_t len, int type)/' "$PROXYCHAINS_SRC"
    
    # Also fix any calls to this function
    sed -i 's/gethostbyaddr(/gethostbyaddr_compat(/' "$PROXYCHAINS_SRC"
    
    echo "Patch applied successfully"
else
    echo "Warning: proxychains source not found, skipping patch"
fi