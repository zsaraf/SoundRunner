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


class Particle : public Entity
{
public:
    Particle() : size( 1, 1, 1.0f ), stacks(10), slices(10) { }
public:
    // update
    virtual void update( double dt );
    
    // render
    virtual void render();

public:
    Vector3D size;
    GLint slices;
    GLint stacks;
private:
};




#endif /* defined(__LBow__Entity__) */
