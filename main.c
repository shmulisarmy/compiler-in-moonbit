#include<stdio.h>
#include <string.h>






typedef unsigned char byte;



int return_address_stack[1024];
int return_address_stack_len = 0;
void set_address(int address){
    return_address_stack[return_address_stack_len] = address;
    return_address_stack_len++;
}
int function_start_address(){
    return return_address_stack[return_address_stack_len-1];
}
byte memory[1024*1024];
byte temp_stack[1024];
int temp_stack_len = 0;
int math_reg;

int return_address(){
    return return_address_stack[return_address_stack_len-1];
}



int main(){
    memcpy(10, memory[0])
    memcpy(memory[0], memory[top of stack])
    memcpy(9, memory[second to top of stack])
    math_reg =top of stack %&^ second to top of stack
    memcpy(math_reg, memory[4])
    memcpy(memory[4], memory[function_start_address()+0])
    memcpy(0, memory[function_start_address()+4])
    set_address(8)
    call function double_it
    memcpy(memory[0], memory[top of stack])
    memcpy(memory[4], memory[second to top of stack])
    math_reg =top of stack %&^ second to top of stack
    memcpy(math_reg, memory[top of stack])
    memcpy(memory[8], memory[second to top of stack])
    math_reg =top of stack %&^ second to top of stack
    memcpy(math_reg, memory[12])
  return 0;
}