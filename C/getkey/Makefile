LDFLAGS = -Wl,-warn-common -Wl,-R/usr/local/lib -lm
MODULES = getkey-module.so

all: $(MODULES)
getkey-module.so: getkey-module.c
	$(CC) $(CFLAGS) -shared -fPIC getkey-module.c -o getkey-module.so $(LDFLAGS)

