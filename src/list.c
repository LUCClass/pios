// list.c

#include "list.h"
#include <stddef.h>


void list_add(struct list_element *list_head, struct list_element *new_element){
  new_element->next = list_head;
  list_head = new_element;
}


void list_remove(struct list_element *element){
  element->next = NULL;
}


int main(){
  struct list_element d = {NULL, 0};
  struct list_element c = {NULL, 0};
  struct list_element b = {&c,   0};
  struct list_element a = {&b,   0};
  struct list_element *head = &a;

  struct list_element *new_item = &d;

  list_add(head, new_item);

  list_remove(head);

  return 0;
}
