// list.c

#include <list.h>;

void list_add(struct list_element *list_head, struct list_element *new_element){
  new_element->next = (*list_head);
  *list_head = new_element;
}


void list_remove(struct list_element *list_head, struct list_element *element_to_remove){
  struct list_element *current_element = (*list_head);
  struct list_element *prev_element = NULL;

  while (*current_element->next != NULL) {
    *prev_element = *current_element;
    *current_element = current_element->next;
    if (current_element == *element_to_remove){
      prev_element->next = current_element->next;
    }
  }
}


int main(){
  struct list_element c = {NULL, 0};
  struct list_element b = {&c,   0};
  struct list_element a = {&b,   0};
  struct list_element *head = &a;

  struct list_element new_item = {NULL, 0};

  list_add(*head, *new_item);

  list_remove();

  return 0;
}
