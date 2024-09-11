
char glbl[128];


void kernel_main() {

  extern int __bss_start, __bss_end;
  char *bss_start, *bss_end;

  bss_start = &__bss_start;
  bss_end = &__bss_end;


  while(1){
  }
}
