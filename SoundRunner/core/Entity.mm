//
//  Entity.mm
//  LBow
//
//  Created by JP Wright on 1/28/14.
//  Copyright (c) 2014 JP Wright. All rights reserved.
//

#import "Entity.h"
#import <array>
#import "renderer.h"

static const GLfloat squareVertices[] = {
    -0.5f,  -0.5f,
    0.5f,  -0.5f,
    -0.5f,   0.5f,
    0.5f,   0.5f,
};


static const GLfloat normals[] = {
    0, 0, 1,
    0, 0, 1,
    0, 0, 1,
    0, 0, 1
};

static const GLfloat texCoords[] = {
    0, 1,
    1, 1,
    0, 0,
    1, 0
};

Entity::Entity()
{
    
    alpha = 1.0;
    active = false;
    
}

Avatar::Avatar(bool isMoving)
{
    this->isMoving = isMoving;
}

// update
void Avatar::update( double dt )
{
    // update!
    GLfloat inc = .3 * dt;

    GLfloat g_gfxWidth = 1024;
    GLfloat g_gfxHeight = 640;
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    alpha -= 0.01;
    if (isMoving)
    {
        loc.set(loc.x + dt*vel.x, + loc.y + dt*vel.y, loc.z + dt*vel.z);
        
        
        if ( loc.y <= -1  )
        {
            active = false;
            //NSLog(@"off screen. deleting.");
        }
        
        // bound
        if (loc.x < Globals::leftBound)
            loc.x = Globals::leftBound;
        if (loc.x > Globals::rightBound)
            loc.x = Globals::rightBound;
        
        sca.x -= inc;
        sca.y -= inc;
        sca.z -= inc;
    }
}



// redner
void Avatar::render()
{
    // enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // set blend func
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc( GL_ONE, GL_ONE );
    
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, Globals::g_texture[0] );
    
    // vertex
    glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // texture coordinate
    glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    
    // triangle strip
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    // disable blend
    glDisable( GL_BLEND );
    glDisable( GL_TEXTURE_2D );
}

/* UGLY UGLY UGLY Find better way */
#define RADIUS_SQUARED .04

GLfloat distanceBetweenTwoVecs( Vector3D vecA, Vector3D vecB)
{
    GLfloat dx_squared = powf(vecA.x - vecB.x, 2);
    if (dx_squared < RADIUS_SQUARED) return FLT_MAX;
    GLfloat dy_squared = powf(vecA.y - vecB.y, 2);
    if (dy_squared < RADIUS_SQUARED) return FLT_MAX;
    return sqrtf(dx_squared + dy_squared);
}

void Particle::update( double dt )
{
    // interp
    size.interp( dt );
    
    // update!
    GLfloat inc = .5 * dt;
    
    GLfloat g_gfxWidth = 1024;
    GLfloat g_gfxHeight = 640;
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    
    if (loc.x < Globals::leftBound || loc.x > Globals::rightBound) {
        vel.x = -1 * vel.x;
    }
    if (loc.y < -1 || loc.y > 1) {
        vel.y = -1 * vel.y;
    }
    
//    if (distanceBetweenTwoVecs(loc, g_avatar->loc) < RADIUS_SQUARED) {
//        col.set(1., 1., 1.);
//    }
    
    loc.x += vel.x;
    loc.y += vel.y;
}

void Particle::render()
{
    // enable texture mapping
    glEnable( GL_TEXTURE_2D );
    // enable blending
    glEnable( GL_BLEND );
    // set blend func
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc( GL_ONE, GL_ONE );
    
    // bind the texture
    glBindTexture( GL_TEXTURE_2D, Globals::g_texture[1] );
    
    // vertex
    glVertexPointer( 2, GL_FLOAT, 0, squareVertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // texture coordinate
    glTexCoordPointer( 2, GL_FLOAT, 0, texCoords );
    glEnableClientState( GL_TEXTURE_COORD_ARRAY );
    
    // triangle strip
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    // disable blend
    glDisable( GL_BLEND );
    glDisable( GL_TEXTURE_2D );
}


NoteBoundary::NoteBoundary(GLfloat xPos)
{
    boundVertices[0] = boundVertices[2] = xPos;
    boundVertices[1] = y1;
    boundVertices[3] = y2;
}

void NoteBoundary::update(double dt)
{
    
}

void NoteBoundary::render()
{
    // enable blending
    glEnable( GL_BLEND );
    // set blend func
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc( GL_ONE, GL_ONE );
    glLineWidth(1.0);
    
    // vertex pointer
    glVertexPointer( 2, GL_FLOAT, 0, boundVertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // line strip
    glDrawArrays( GL_LINE_STRIP, 0, 2);
    
 
    // disable blend
    glDisable( GL_BLEND );
}




