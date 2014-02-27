//
//  Entity.h
//  LBow
//
//  Created by JP Wright on 1/28/14.
//  Copyright (c) 2014 Ge Wang. All rights reserved.
//

#ifndef __Runner__Entity__
#define __Runner__Entity__


#import <iostream>
#import "mo_gfx.h"
#import "mo_glut.h"
#import "Globals.h"



class Entity
{
public:
    // constructor
    Entity(); 
    
    // update
    virtual void update( double dt )
    { }
    // redner
    virtual void render()
    { }
    
public:
    Vector3D loc;
    Vector3D ori;
    Vector3D sca;
    Vector3D col;
    // the ever important velocity vector.
    Vector3D vel;
    GLfloat alpha;
    GLboolean active;
    // texture
    GLuint e_texture[1];
};


class Avatar : public Entity
{
public:
    Avatar(bool fade);
    // update
    virtual void update( double dt );
    
    // render
    virtual void render();
    bool isMoving;
private:
    bool fadeOut;
};




class String : public Entity
{
public:
    // constructor
    String(Vector3D *a, Vector3D *b, float start_freq, float halfWidth);
    
public:
    // udpate
    virtual void update( double dt );
    // render
    virtual void render();
    
    // set the ends of the String
    void setPointA(GLfloat x, GLfloat y);
    void setMidpoint(GLfloat x, GLfloat y);
    void setPointB(GLfloat x, GLfloat y);
    
private:
    Vector3D pointA, midpoint, pointB;
    GLfloat stringVertices[6];
    GLfloat stringRectVertices[8];
};





class Sphere : public Entity
{
public:
    Sphere() : size( 1, 1, 1.0f ), stacks(10), slices(10) { }
public:
    // update
    virtual void update( double dt );
    
    // render
    virtual void render();
    
public:
    Vector3D size;
    GLint slices;
    GLint stacks;
    bool isMoving;

};



#endif /* defined(__LBow__Entity__) */
