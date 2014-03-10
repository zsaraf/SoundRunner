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
    alpha -= 0.1;
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
        
//        sca.x += inc;
//        sca.y += inc;
//        sca.z += inc;
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
#define RADIUS .2
#define RADIUS_SQUARED .04

GLfloat distanceBetweenTwoVecs( Vector3D vecA, Vector3D vecB)
{
    GLfloat dx = vecA.x - vecB.x;
    if (dx > RADIUS) return FLT_MAX;
    GLfloat dy = vecA.y - vecB.y;
    if (dy > RADIUS) return FLT_MAX;
    return sqrtf(powf(dx, 2) + powf(dy,2));
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
    
    Entity *avatar = getCurrentAvatar();
    
    GLfloat dist = distanceBetweenTwoVecs(loc, avatar->loc);
    
    if (dist < avatar->sca.x/2) {
//        col.set(1., 1., 1.);
        GLfloat dx = loc.x - avatar->loc.x;
        GLfloat dy = loc.y - avatar->loc.y;
        loc.set(avatar->loc.x + RADIUS/dist * dx, avatar->loc.y + RADIUS/dist * dy, 0);
    } else {
        loc.x += vel.x;
        loc.y += vel.y;
    }
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

ScrollMap::ScrollMap(GLfloat * leftClip, GLfloat * rightClip)
{
    margin = 0.06;
    top = 0.97;
    height = 0.02;
    leftEdge = leftClip;
    rightEdge = rightClip;
    width = (*rightEdge - margin) - (*leftEdge + margin);
    
    for ( int i = 0; i < numVertices; i += 4 )
    {
        vertices[i] = *leftEdge + margin;
        vertices[i+2] = *rightEdge - margin;
        vertices[i + 1] = vertices[i+3] = top - i*height;
        
    }
}

void ScrollMap::update(double dt)
{
    for ( int i = 0; i < numVertices; i += 4 )
    {
        vertices[i] = *leftEdge + margin;
        vertices[i+2] = *rightEdge - margin;
        vertices[i + 1] = vertices[i+3] = top - i*height;
        
    }
}

void ScrollMap::render()
{
    // enable blending
    glEnable( GL_BLEND );
    // set blend func
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc( GL_ONE, GL_ONE );
    glLineWidth(1.0);
    
    // vertex pointer
    glVertexPointer( 2, GL_FLOAT, 0, vertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // line strip
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4);
    
    
    // disable blend
    glDisable( GL_BLEND );
}




ScrollAvatar::ScrollAvatar(ScrollMap * scrollMap, GLfloat * nextAvX, GLfloat width)
{
    nextAvatarX = nextAvX;
    theMap = scrollMap;
    theWidth = width;
    GLfloat percent = (*nextAvatarX - Globals::leftBound)/(Globals::rightBound - Globals::leftBound);
    for ( int i = 0; i < numVertices; i += 4 )
    {
        vertices[i] = *(theMap->leftEdge) + theMap->margin + percent*theMap->width - theWidth;
        vertices[i+2] = *(theMap->leftEdge) + theMap->margin + percent*theMap->width + theWidth;
        vertices[i + 1] = vertices[i+3] = theMap->top - i*theMap->height;
        
    }
}

void ScrollAvatar::update(double dt)
{
    GLfloat percent = (*nextAvatarX - Globals::leftBound)/(Globals::rightBound - Globals::leftBound);
    for ( int i = 0; i < numVertices; i += 4 )
    {
        vertices[i] = *(theMap->leftEdge) + theMap->margin+ percent*theMap->width - theWidth;
        vertices[i+2] = *(theMap->leftEdge) + theMap->margin + percent*theMap->width + theWidth;
        vertices[i + 1] = vertices[i+3] = theMap->top - i*theMap->height;
        
    }
}


void ScrollAvatar::render()
{
    // enable blending
    glEnable( GL_BLEND );
    // set blend func
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc( GL_ONE, GL_ONE );
    glLineWidth(1.0);
    
    // vertex pointer
    glVertexPointer( 2, GL_FLOAT, 0, vertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // line strip
    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4);
    
    
    // disable blend
    glDisable( GL_BLEND );
}



