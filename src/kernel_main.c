extern int __bss_start;
extern int __bss_end;

unsigned int global_var;


void kernel_main() {
  char *begin_bss = &__bss_start;
  char *end_bss   = &__bss_end;

  for (int *current_bss = *begin_bss; *current_bss < *end_bss; *current_bss++){
    *current_bss = 0;
  }
}
