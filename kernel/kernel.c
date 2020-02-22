#include <kernel.h>

const char hello[] = "Hello World";

void init(uint32_t magic, struct mb_info *mbi) {
  for (char *c = (char *)hello; *c != 0; c++)
    put(*c);
  put('\n');
}
