
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
struct DataPair{
    char state[64];
    float longitude;
    float latitude;
    
};



struct DataPair * parse(const char * path){
    
    
    // xcode and opening files SUCKS
    // fuck
    // why
    
    
    printf("Path is %s\n",path);
    char longFileName[256];
    char statFileName[256];
    char * last = stpcpy(longFileName,path);
    strcpy(last,"/longitudes.txt");
    char * stateLast = stpcpy(statFileName,path);
    strcpy(stateLast,"/states.txt");
    
    FILE * longLatFile = fopen(longFileName,"r");
    FILE * stateFile = fopen(statFileName,"r");
   //                         longitudes.txt
    if(longLatFile == NULL){printf("LongLat file was NULL\n");}
    if(stateFile == NULL){printf("stateFile file was NULL\n");}
    
    
        
    struct DataPair * toReturn = (struct DataPair *)malloc(sizeof(struct DataPair) * 52);
    int i = 0;
    while(i < 50){
        
        fscanf(stateFile,"%s",toReturn[i].state);
        // every even float in the longitudes file corresponseds to a latitude
        // every odd one corresponds to a longitude
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