//
//  GeoFenceTracker.m
//  UnlimitedGeoNotificationSystem
//
//  Created by joshua on 6/9/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#import "GeoFenceTracker.h"
#include <map>
#include <string>
// latitude is y
// longitude is x
@interface GeoFenceTracker(){
    Algo::QuadTree * qt;
    std::map<std::pair<Precision,Precision> ,std::string> pointMapping;
    std::vector<CGPoint *>  * toFree;
    unsigned int numPointsTracking;
}@end
CGRect dummy = CGRectMake(0, 0, 0, 0);
@implementation GeoFenceTracker
typedef Algo::QuadPoint<Precision> QPoint;

-(instancetype)init{
    NSLog(@"Dont call me\n");
    
    exit(0);
}

-(instancetype)initWithCGRect:(struct CGRect)rect{
    self = [super init];
    
    // it auto static casted everything holla @ ya boi
    qt = new Algo::QuadTree({static_cast<Precision>(rect.origin.x),static_cast<Precision>(rect.origin.y),static_cast<Precision>(rect.size.width),static_cast<Precision>(rect.size.height)});
    toFree = new std::vector<CGPoint *>();
    
    
    return self;
}
+(QPoint) convertFromNegativeSystem:(Precision) longitude
                           withWhy :(Precision) latitude{
    QPoint toReturn = {longitude+180.0f,latitude+90.0f};
    return toReturn;
}

+(Algo::Rect) convertFromNegativeSystem:(CGRect) otherRect{
    Algo::Rect toReturn;
    toReturn.upperLeft = {static_cast<float>(otherRect.origin.x+180.0f),static_cast<float>(otherRect.origin.y+90.0f)};
    toReturn.width = otherRect.size.width;
    toReturn.height = otherRect.size.height;
    
    return toReturn;
}
+(CGPoint) convertToMapSystem:(QPoint) q{
    CGPoint toReturn = {q.x - 180.0,q.y - 90.0};
    return toReturn;
    
}
+(GeoFenceTracker *) getSingleton:(struct CGRect) withThisRect{
    static GeoFenceTracker * store = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        if(withThisRect.size.height == 0 && withThisRect.size.width == 0){
            NSLog(@"Error you are trying to intialize with the dummy retangle");
            exit(0);
        }
        store = [[GeoFenceTracker alloc]initWithCGRect:withThisRect];
    });
    
    return store;
}
+(CGPoint *) getCurrentTrackedLocations{
    // maybe call malloc instead
    // root of erros was new
    //new CGPoint[[GeoFenceTracker getSingleton:dummy]->numPointsTracking +1];
    struct CGPoint * toReturn = (CGPoint *)malloc(sizeof(struct CGPoint) * ([GeoFenceTracker getSingleton:dummy]->numPointsTracking +1));
    //
    // isnt c++ marvelous?!?!
    unsigned int i = 0;
    for(std::map<std::pair<Precision,Precision>,std::string>::iterator iter =
        [GeoFenceTracker getSingleton:dummy]->pointMapping.begin(); iter !=  [GeoFenceTracker getSingleton:dummy]->pointMapping.end(); iter++ ){
        QPoint point = {iter->first.first,iter->first.second};
        CGPoint toAdd = [GeoFenceTracker convertToMapSystem:point];
        toReturn[i++] = toAdd;
    }
    
   
    // il manage zee memory
    //[GeoFenceTracker getSingleton:dummy]->toFree->push_back(toReturn);
    toReturn[i] = CGPointMake(SENTINEL, SENTINEL);
    return toReturn;
}
+(NSString *) getStringForKey:(float) longitude
                      withLat:(float) latitude{
    
    if([GeoFenceTracker getSingleton:dummy]->pointMapping.find({longitude,latitude}) != [GeoFenceTracker getSingleton:dummy]->pointMapping.end()){
        NSString * toReturn = [[NSString alloc] initWithUTF8String:[GeoFenceTracker getSingleton:dummy]->pointMapping[{longitude,latitude}].c_str()];
        return toReturn;
    }else{
        return @"";
    }
    
}
+(void)insertNotification:(float)longitude
            withLatitude:(float)latitude
             withPayLoard:(NSString *)message{
    QPoint point = [self convertFromNegativeSystem:longitude withWhy:latitude];
    [GeoFenceTracker getSingleton:CGRectMake(0,0,0,0)]->qt->insert(point);
    std::string value = std::string([message UTF8String]);
    // stl + objective c = worst possible code on the planet
    if([GeoFenceTracker getSingleton:dummy]->pointMapping.find({point.x,point.y}) != [GeoFenceTracker getSingleton:dummy]->pointMapping.end()){
        //add to it
        value = [GeoFenceTracker getSingleton:CGRectMake(0,0,0,0)]->pointMapping[{point.x,point.y}];
         value += std::string([message UTF8String]);
        [GeoFenceTracker getSingleton:CGRectMake(0,0,0,0)]->pointMapping[{point.x,point.y}] = value;
    }else{
        [GeoFenceTracker getSingleton:CGRectMake(0,0,0,0)]->pointMapping.insert({{point.x,point.y},value});
    }
    [GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking++;

    
}

+(void)deleteNotification:(float)longitude
            withLatitude:(float)latitude{
    
    QPoint point =  [self convertFromNegativeSystem:longitude withWhy:latitude];

    [GeoFenceTracker getSingleton:CGRectMake(0,0,0,0)]->qt->remove(point);
    [GeoFenceTracker getSingleton:CGRectMake(0,0,0,0)]->pointMapping.erase({point.x,point.y});
    [GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking--;

}
+(void) loadFromFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *path= [NSString stringWithFormat:@"%@/geoStore.txt",
                          documentsDirectory];
    
    FILE * toOpen = fopen([path UTF8String],"rb");
    if(toOpen == NULL){
        printf("Error writing to file :(\n");
        return;
    }
    // else write
    unsigned int sizeOfPair = sizeof(typeof(Precision)) *2;
    unsigned int blockSize = 0;
    unsigned int sizeOfString = 0;
    // Format ([x][y][sizeofstring][string])*
    // aka      [x][y][sizeofstring][string][x][y][sizeofstring][string]..... all your disk
    // in bytes  4  4        4        any
    
    unsigned int numItems;
    if(fread(&numItems, sizeof(unsigned int), 1, toOpen) == EOF){
        printf("Error reading the file");
        fclose(toOpen);
        return;
    }
    // THERE IS GARBAGE IN THE STORAGE YOU NEED TO CHECK AHEAD OF TIME FOR DATA CORRUPTION!!
    // fread does advance the file pointer
    std::pair<Precision,Precision> point;
    std::string str;
    unsigned int strLen;
    // error is between 8 9 and 10
    for(int i = 0; i < numItems; i++){
        
        if(fread(&point.first,sizeof(Precision),1,toOpen) == EOF){printf("Error reading in a coordinate  for the file \n");fclose(toOpen);return;}
        if(fread(&point.second,sizeof(Precision),1,toOpen) == EOF){printf("Error reading in a coordinate for the file \n");fclose(toOpen);return;}
        if(fread(&strLen,sizeof(unsigned int),1,toOpen) == EOF){printf("Error reading in string length for the file \n");fclose(toOpen);return;}
        char * buff  = (char *)malloc((strLen) * sizeof(char));
        
        
        memset(buff,0,(strLen)*sizeof(char));
        if(fread(buff,strLen,1,toOpen) == EOF){printf("Error reading in a string for the file \n");fclose(toOpen);return;}
       
        /*if(buff[strLen-1] != '\0'){
            printf("buff[strlen] %c",buff[strLen]);
            printf("COULD BE HUGE ERROR NON NULL TERMINATED\n");
        }
         
        printf("Read %f %f %s\n",point.first,point.second,buff);
       
        // its reading the points back in reverse order why?? endieness?
        */
        
       
        if(strLen > 1){
        
            std::string toAdd = std::string(buff);
            [GeoFenceTracker getSingleton:dummy]->pointMapping.insert(std::pair<std::pair<Precision,Precision>, std::string>({point.first,point.second},toAdd.c_str()));
                //printf("After inserting the size is %d\n",[GeoFenceTracker getSingleton:dummy]->pointMapping.size());
          
            [GeoFenceTracker getSingleton:dummy]->qt->insert({point.first,point.second});
            [GeoFenceTracker getSingleton:dummy]->numPointsTracking++;
        }
        free(buff);
        
    }
    
    // write how many their are
    
    fclose(toOpen);
}
+(void) writeToFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/geoStore.txt",
                          documentsDirectory];
    
    //create content - four lines of text
   
    // this is a check ^^^ to see what happens
    
    
    // I am unable to open the file I am guessing I don't have write permissions
    // And i found an apple doc within a minute saying I cannot write to AppName.app director makes sense!
    // write to /Documents/
    // BUT OF COURSE IT SOMEHOW DOESNT WORK
    // nothing every just works on ios...
  
    FILE * toWrite = fopen([fileName UTF8String],"wb");
    if(toWrite == NULL){
        printf("Error writing to file :(\n");
        perror("Checking write error\n");
        return;
    }
    // else write
    unsigned int sizeOfPair = sizeof(typeof(Precision)) *2;
    unsigned int blockSize = 0;
    unsigned int sizeOfString = 0;
    // Format ([x][y][sizeofstring][string])*
    // aka      [x][y][sizeofstring][string][x][y][sizeofstring][string]..... all your disk
    // in bytes  4  4        4        any
    
    unsigned int numItems = (unsigned int)[GeoFenceTracker getSingleton:dummy]->pointMapping.size();
    
    // write how many their are.
    fwrite(&numItems, sizeof(unsigned int), 1, toWrite);

    
     for(auto iter : [GeoFenceTracker getSingleton:dummy]->pointMapping){
        // write the first and second
         // it returns the value in bytes
        sizeOfString = (unsigned int)iter.second.size() + 1;
         // fwrite(void *, size_t size, size_t nitems (writes nitems objects each size bytes long), FILE)
         
         if(sizeOfString < 1){
             // do nada
             continue;
         }
          blockSize = sizeOfPair + sizeof(unsigned int) + sizeOfString;
         char block[blockSize];
         memset(block,0,sizeof(block));
         printf("The size of block is %d\n",sizeof(block));
         memcpy(block,&iter.first.first,sizeof(Precision));
         memcpy(block+sizeof(Precision),&iter.first.second,sizeof(Precision));
         memcpy(block + sizeOfPair,&sizeOfString,sizeof(unsigned int));
         memcpy(block + sizeOfPair + sizeof(unsigned int),iter.second.c_str(),sizeOfString);
         if(block[blockSize-1] != '\0'){
             printf("Potentially huge error the null char wasnt read instead %c \n",block[blockSize]);
         }
         printf("Size of char is %d\n",sizeof(char));
         printf("Inserting %f %f %d %s\n",iter.first.first,iter.first.second,blockSize,iter.second.c_str());
         fwrite(block, blockSize, 1, toWrite);
         
    }
    
    fclose(toWrite);
    
}
// this assumes you pass in the basic scrub rect
+(void)printAllPointsIntersecting:(CGRect) rect{
    

    // convert it
    Algo::Rect theRec = [self convertFromNegativeSystem:rect];
    theRec.upperLeft.x -= theRec.width/2;
    theRec.upperLeft.y -= theRec.height/2;

    std::vector<QPoint> intersected;
    
    Algo::QuadQuery::query([GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->qt, theRec, intersected);
    printf("\nTracking %d points \n",[GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking);
    for(int i = 0; i < intersected.size();i ++){
        CGPoint p =[self convertToMapSystem:intersected[i]];
       
        std::string toPrint = [GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->pointMapping.at({intersected[i].x,intersected[i].y});
        /* IN ORDER FOR IT TO MAKE SENSE YOU NEED TO CONVER COORDINATES BACK
         */
        
        printf("We intersected location x(%f) y(%f) with payload %s\n",p.x,p.y,toPrint.c_str());
    }
}
+(NSMutableArray *) getNotifications:(CGRect) rect{
    Algo::Rect theRec = [self convertFromNegativeSystem:rect];
    theRec.upperLeft.x -= theRec.width/2;
    theRec.upperLeft.y -= theRec.height/2;
    
    std::vector<QPoint> intersected;
    NSMutableArray * toReturn = [[NSMutableArray alloc]init];
    Algo::QuadQuery::query([GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->qt, theRec, intersected);
    //printf("\nTracking %d points \n",[GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->numPointsTracking);
    for(int i = 0; i < intersected.size();i ++){
        std::string toAdd = [GeoFenceTracker getSingleton:CGRectMake(0, 0, 0, 0)]->pointMapping.at({intersected[i].x,intersected[i].y});
       // printf("We intersected location x(%f) y(%f) with payload %s\n",intersected[i].x,intersected[i].y,toPrint.c_str());
        [toReturn addObject:[NSString stringWithUTF8String:toAdd.c_str()]];
         
    }
         
        return toReturn;
}
/*
-(void)dealloc{
    //[super dealloc];
    for(CGPoint * freeMe : *toFree){
        delete freeMe;
    }
    
    delete toFree;
    delete qt;
}
*/
@end


