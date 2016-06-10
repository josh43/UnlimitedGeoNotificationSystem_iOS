
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
struct DataPair{
    char state[64];
    float longitude;
    float latitude;
    
};



struct DataPair * parse(){
    
    
    // xcode and opening files just fucking sucks so bad
    // fuck
    // why
    
    
    FILE * open = fopen("test.out","w");
    fprintf(open,"WHERE IS THIS");
    fclose(open);
    FILE * longLatFile = fopen("/GPX/longitudes.txt","r");
    FILE * stateFile = fopen("Users/josh/Documents/CS\x20Projects/UnlimitedGeoNotificationSystem/UnlimitedGeoNotificationSystem/GPX/states.txt","r");
   //                         longitudes.txt
    if(longLatFile == NULL){printf("LongLat file was NULL\n");}
    if(stateFile == NULL){printf("stateFile file was NULL\n");}
    
    
        
    struct DataPair * toReturn = (struct DataPair *)malloc(sizeof(struct DataPair) * 52);
    int i = 0;
    while(i < 50){
        fscanf(stateFile,"%s",toReturn[i].state);
        fscanf(longLatFile,"%f",&toReturn[i].latitude);
        fscanf(longLatFile,"%f",&toReturn[i].longitude);
        i++;
    }
    
    
    toReturn[51].longitude = 0;
    toReturn[51].latitude= 0;
    
    fclose(longLatFile);
    fclose(stateFile);
    
    return toReturn;
    
}