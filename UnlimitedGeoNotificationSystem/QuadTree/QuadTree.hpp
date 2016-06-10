 //
//  QuadTree.hpp
//  QuadTreePlusPlus
//
//  Created by joshua on 6/8/16.
//  Copyright © 2016 joshua. All rights reserved.
//

#ifndef QuadTree_hpp
#define QuadTree_hpp

#include <stdio.h>
#include <vector>
#include <math.h>


typedef float Precision;

#define SENTINEL -500.0
#define MARGIN .000001
#define PARENT -600.0
namespace Algo {
    template<typename T>
    struct QuadPoint{
        
        T x;
        T y;
        
        QuadPoint(T xx , T yy):x(xx),y(yy){
            
        }
        QuadPoint():QuadPoint(0,0){}
        
        // I am keeping it like pointers because I was using a c99 compiler on last version of xcode and was too laz e to change
        // someone can change to & which would be nicer :D
        void printSelf(){
            // riiskeeeee
            printf("Point x(%f) y(%f) \n",x,y);
        }
        static bool equal(const struct QuadPoint * pointOne, const  struct QuadPoint * pointTwo, float margin){
            
            float xRes = fabs(pointOne->x - pointTwo->x);
            float yRes = fabs(pointOne->y - pointTwo->y);
            
            if(xRes > margin || yRes > margin){
                return false;
            }
            return true;
        }
    };
    // I should just typedef this  QuadPoint<Precision> point but laz e
    struct Rect{
        QuadPoint<Precision> upperLeft;
        Precision width;
        Precision height;
        Rect():upperLeft(),width(0),height(0){
            
        }
        Rect(QuadPoint<Precision> point, Precision w,Precision h):upperLeft(point),width(w),height(h){}
        Rect(Precision x, Precision y, Precision w,Precision h):Rect({x,y},w,h){}
        
        Precision getWidthOffsetFromPoint() const{
            return this->width + this->upperLeft.x;
        }
        Precision getHeightOffsetFromPoint() const{
            return this->height + this->upperLeft.y;
        }
        Rect getIntersection(const Rect & other){
            
            if(Rect::rectIsInside(*this, other)){
                // i totally contain the other so just return it
                return other;
            }else if(Rect::rectIsInside(other, *this)){
                // the other totally contains me return this
                return *this;
            }else{
                Precision xStart = this->upperLeft.x  > other.upperLeft.x ? this->upperLeft.x : other.upperLeft.x;
                Precision yStart = this->upperLeft.y > other.upperLeft.y ? this->upperLeft.y : other.upperLeft.y;
                
                if(Rect::contains(*this, {xStart,yStart}) && Rect::contains(other,{xStart,yStart})){
                    // yay I am not sure if this is the most efficient algo it just made sense to me and was easy
                    Precision width = this->getWidthOffsetFromPoint() < other.getWidthOffsetFromPoint() ? this->getWidthOffsetFromPoint() : other.getWidthOffsetFromPoint();
                    Precision height = this->getHeightOffsetFromPoint() < other.getHeightOffsetFromPoint() ? this->getHeightOffsetFromPoint() : other.getHeightOffsetFromPoint();
                    width-=xStart;
                    
                    height-=yStart;
                    return Rect(xStart,yStart,width,height);
                } //else do nothing
                
            }
            
            return Rect(SENTINEL,SENTINEL,SENTINEL,SENTINEL);
        }
        static bool contains(const struct Rect & rec,const struct QuadPoint<Precision> &  p){
            if(rec.upperLeft.x > p.x || rec.upperLeft.x + rec.width < p.x){
                return false;
            }else if(rec.upperLeft.y > p.y || rec.upperLeft.y + rec.height < p.y){
                return false;
            }
            
            return true;
        }
        
        // we are testing if the second rectangle is insidethe first
        static bool rectIsInside(const struct Rect & rec,const struct Rect &  p){
            if(!(rec.upperLeft.y <= p.upperLeft.y && rec.upperLeft.y + rec.height >= p.upperLeft.y+ p.height)){
                return false;
            }else if(!(rec.upperLeft.x <= p.upperLeft.x && rec.upperLeft.x + rec.width >= p.upperLeft.x+ p.width)){
                return false;
            }
            
            
            return true;
        }
        
        
        
    };
    
    
    /* TODO:
     Make a removeRange(), basically just rangeQuery but instead set points to null!
     Also as bonus you can potentially collapse quad nodes and free memory making the tree smaller
     
     Can make a max height, upon reaching it you can have a vector that just holds a bunch of points
     Ex you only want the height to be max of 10 because that is good enough precision, once reached thier
     stop splitting rather just create a node that has a list of points
     
     Make a class that Wraps this and provides basic statistics, aka  numberNodes,height,total heap memory, total   stack memory, avg insertTime, avg queryTime,4
     */
    
    class QuadTree{
    public:
        friend class QuadQuery;
        enum QUAD{
            NW=0,
            NE=1,
            SW=2,
            SE=3
        };
        Rect myRect;
        QuadTree * children[4];
        QuadPoint<Precision> data;
        
        QuadTree(Rect s):myRect(s){
            for(int i = 0; i < 4; i ++){
                children[i] = nullptr;
            }
            data.x = SENTINEL;
            data.y = SENTINEL;
            
        }
        ~QuadTree(){
            for(int i = 0; i < 4; i ++){
                if(children[i]){
                    delete children[i];
                }
            }
            
        }
        
        void insert(QuadPoint<Precision> point){
            this->insert(this,point);
        }
        void remove(QuadPoint<Precision> point){
            this->remove(this,point);
            
        }
        
    protected:
        bool remove(QuadTree * head, QuadPoint<Precision> point){
            if(!Rect::contains(head->myRect, point)){
                return false;
            }
            // else proceed
            
            if(point.x == SENTINEL){
                printf("Error you can't set the x to the sentinel :|||");
                exit(0);
                //throw std::invalid_argument("NOO X IS SENTINEL FAIL");
            }
            if(QuadPoint<Precision>::equal(&head->data,&point,MARGIN)){
                head->data.x = SENTINEL;
                head->data.y = SENTINEL;
                return true; // dont do anythng
            }
            if(head->data.x == SENTINEL && head->data.y == SENTINEL){
                return false;
            }
            
            bool res = false;
            
            for(int i =0; i < 4; i ++){
                if(head->children[i] != NULL){
                    // try and insert into as many as you can
                    res |= remove(head->children[i],point);
                }
            }
            
            return res;
            
        }
        bool insert(QuadTree * head,  QuadPoint<Precision> point){
            
            if(!Rect::contains(head->myRect, point)){
                return false;
            }
            // else proceed
            
            if(point.x == SENTINEL){
                printf("Error you can't set the x to the sentinel :|||");
                exit(0);
                //throw std::invalid_argument("NOO X IS SENTINEL FAIL");
            }
            if(QuadPoint<Precision>::equal(&head->data,&point,MARGIN)){
                return true; // dont do anythng
            }
            if(head->data.x == SENTINEL && head->data.y == SENTINEL){
                head->data = point;
                return true;
            }
            
            bool res = false;
            
            for(int i =0; i < 4; i ++){
                if(head->children[i] != NULL){
                    // try and insert into as many as you can
                    res |= insert(head->children[i],point);
                }
            }
            
            if(res == false){
                // than create one
                // aka split nodes
                head->split();
                // try again yall
                // all data is at leaves dont forget to add this data
                QuadPoint<Precision> parentNode = {PARENT,PARENT};
                QuadPoint<Precision> toInsert = head->data;
                head->data= parentNode;
                insert(head,toInsert);
                
                return insert(head,point);
                
            }else{
                return true;
            }
            
        }
        void split(){
            // NE
            // check this out
            Rect NW = {myRect.upperLeft,
                myRect.width/2,
                myRect.height/2};
            Rect NE = {myRect.upperLeft.x +myRect.width/2, //x
                myRect.upperLeft.y, // y
                myRect.width/2, // w
                myRect.height/2}; //h
            Rect SW = {myRect.upperLeft.x ,
                myRect.upperLeft.y +myRect.height/2,
                myRect.width/2,
                myRect.height/2};
            Rect SE = {myRect.upperLeft.x +myRect.width/2 ,
                myRect.upperLeft.y + myRect.height/2,
                myRect.width/2,
                myRect.height/2};
            
            children[QUAD::NW] = new QuadTree(NW);
            children[QUAD::NE] = new QuadTree(NE);
            children[QUAD::SW] = new QuadTree(SW);
            children[QUAD::SE] = new QuadTree(SE);
        }
        
        
    };
    
    
    
    class QuadQuery{
        
    public:
        static void query(QuadTree * q,Rect currentRange, std::vector<QuadPoint<Precision> > & pointList){
            if(Rect::rectIsInside(currentRange, q->myRect)){
                // add all
                addAll(q,pointList);
            }else{
                // calculate intersection of every quadrant with current children if they are not null and if the intersection is valid
                // query again  big money big money
                if(q->children[0] != nullptr){
                    // calculate intersection of all
                    Rect nw = q->children[0]->myRect.getIntersection(currentRange);
                    Rect ne = q->children[1]->myRect.getIntersection(currentRange);
                    Rect sw = q->children[2]->myRect.getIntersection(currentRange);
                    Rect se = q->children[3]->myRect.getIntersection(currentRange);
                    
                    if(nw.width != SENTINEL){
                        query(q->children[0],nw,pointList);
                    }
                    if(ne.width != SENTINEL){
                        query(q->children[1],ne,pointList);
                    }
                    if(sw.width != SENTINEL){
                        query(q->children[2],sw,pointList);
                    }
                    if(se.width != SENTINEL){
                        query(q->children[3],se,pointList);
                    }
                }else{
                    
                    //check if the current range covers the point!
                    // because we should be at a child!
                    if(q->data.x != SENTINEL && q->data.x != PARENT){
                        if(Rect::contains(currentRange, q->data)){
                            pointList.push_back(q->data);
                        }
                    }
                }
                // else return were done you cant query with children
                
            }
        }
        static void addAll(QuadTree * node,std::vector<QuadPoint<Precision> > & pointList){
            
            if(node->children[0] != nullptr){
                QuadQuery::addAll(node->children[0],pointList);
                QuadQuery::addAll(node->children[1],pointList);
                QuadQuery::addAll(node->children[2],pointList);
                QuadQuery::addAll(node->children[3],pointList);
            }else{
                if(node->data.x != SENTINEL && node->data.x != PARENT)
                pointList.push_back(node->data);
                // it was null add it
            }
        }
        
        
        static void queryWithKeptIntersections(QuadTree * q,Rect currentRange, std::vector<QuadPoint<Precision> > & pointList,std::vector<Rect > & subQueries){
            if(Rect::rectIsInside(currentRange, q->myRect)){
                // add all
                addAll(q,pointList);
            }else{
                // calculate intersection of every quadrant with current children if they are not null and if the intersection is valid
                // query again brah big money big money
                if(q->children[0] != nullptr){
                    // calculate intersection of all
                    
                    Rect nw = q->children[0]->myRect.getIntersection(currentRange);
                    Rect ne = q->children[1]->myRect.getIntersection(currentRange);
                    Rect sw = q->children[2]->myRect.getIntersection(currentRange);
                    Rect se = q->children[3]->myRect.getIntersection(currentRange);
                    
                    /* These two should be equivalent, intersection should matter who comes first!
                    Rect nw = currentRange.getIntersection(q->children[0]->myRect);
                    Rect ne = currentRange.getIntersection(q->children[1]->myRect);
                    Rect sw = currentRange.getIntersection(q->children[2]->myRect);
                    Rect se = currentRange.getIntersection(q->children[3]->myRect);
                     */
                    if(nw.width != SENTINEL){
                        subQueries.push_back(nw);
                        query(q->children[0],nw,pointList);
                    }
                    if(ne.width != SENTINEL){
                        subQueries.push_back(ne);
                        query(q->children[1],ne,pointList);
                    }
                    if(sw.width != SENTINEL){
                        subQueries.push_back(sw);
                        query(q->children[2],sw,pointList);
                    }
                    if(se.width != SENTINEL){
                        subQueries.push_back(nw);
                        query(q->children[3],se,pointList);
                    }
                }
                // else return were done you cant query with children
                
            }
        }
    private:
        
        
        
        
    };
}
#endif /* QuadTree_hpp */
