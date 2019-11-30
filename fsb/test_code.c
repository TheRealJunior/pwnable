#include <stdio.h>

int main(){
	int num_of_written = 0;
	// i want to write deadbeef
	printf("%48879x%hn\n", 10, &num_of_written);
	printf("1: %x\n", num_of_written);

	printf("%57005x%hn\n", 10, (char*)&num_of_written + 2);
	printf("2: %x\n", num_of_written);

	printf("%1x\n", 0xff);

	printf("%llu", strtoull("652835029144", 0, 10));
}
