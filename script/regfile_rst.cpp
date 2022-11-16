#include <stdio.h>
int main(){
    freopen("out","w",stdout);
    for(int i=0;i<32;i++){
        printf("rf[%2d] <= 64'b0;\n",i);
    }
    return 0;
}