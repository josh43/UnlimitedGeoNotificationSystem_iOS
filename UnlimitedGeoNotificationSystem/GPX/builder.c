#include <string.h>
#include <stdio.h>
#include <stdlib.h>

/*
<wpt lat="37.409197" lon="-122.099444">
            <name>Monta Loma Park</name>
        </wpt>
*/

/*
  I used egrep -o "PATTERN" "FILEHERE"  to split the data into different files
 
 */
void printLat(FILE * outFile,float lat, float lon){

	fprintf(outFile,"<wpt lat=\"%f\" lon=\"%f\">\n",lat,lon);
}
void printName(FILE * outFile,const char * name){

	fprintf(outFile,"<name>%s</name>\n",name);
}
void printTime(FILE * outFile, int currTime){
    //        <time>2010-01-01T00:00:00Z</time>
    
    fprintf(outFile,"<time>2010-01-01T00:00:0%dZ</time>\n",currTime);
}

void printEnd(FILE * outFile){

	fprintf(outFile,"</wpt>\n");
}


int main(int argc, char * argv[]){
	if(argc < 3){
		printf("You need to prvoide 4 args\n");
		exit(0);
	}
	FILE * longLatFile = fopen(argv[1],"r");
	FILE * stateFile = fopen(argv[2],"r");
	FILE * outFile = fopen(argv[3],"w");
    
    printf("argv[1] was %s \n",argv[1]);

	if(longLatFile == NULL){printf("LongLat file was NULL\n");exit(0);}
	if(stateFile == NULL){printf("stateFile file was NULL\n");exit(0);}
	if(outFile == NULL){printf("outFile file was NULL\n");exit(0);}


	float longitude;float latitude;char buff[64];
	int numStates = 51;
    int time = 3;
	while(numStates--){
		fscanf(stateFile,"%s",buff);
		fscanf(longLatFile,"%f",&latitude);
		fscanf(longLatFile,"%f",&longitude);
		printLat(outFile,latitude,longitude);
		printName(outFile,buff);
       // printTime(outFile,time);
        time++;
		printEnd(outFile);
		memset(buff,0,sizeof(buff));
	}



	fclose(longLatFile);
	fclose(stateFile);
	fclose(outFile);


	return 0;
}