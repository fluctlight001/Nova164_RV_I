#include <stdio.h>
int main (){
    int ans[10] = {1,2,3,4,5,6,7,8,9,10};
    int key[10] = {10,9,8,7,6,5,4,3,2,1};
    int pass;
    pass = 1;
    for(int i=0;i<10;i++){
        if (ans[i]!=key[i]){
            pass = 0;
            break;
        }
    }
    if (pass) printf("pass!\n");
    else printf("error!\n");
    return 0;
}