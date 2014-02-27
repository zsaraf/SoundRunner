//
//  Entity.mm
//  LBow
//
//  Created by JP Wright on 1/28/14.
//  Copyright (c) 2014 JP Wright. All rights reserved.
//

#import "Entity.h"
#import <array>

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

Avatar::Avatar(bool fade)
{
    fadeOut = fade;
}

// update
void Avatar::update( double dt )
{
    // update!
    GLfloat inc = .5 * dt;

    GLfloat g_gfxWidth = 1024;
    GLfloat g_gfxHeight = 640;
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    if (isMoving)
    {
        loc.set(loc.x + dt*vel.x, + loc.y + dt*vel.y, loc.z + dt*vel.z);
        
        if ( loc.x <= -ratio )
        {
            loc.x = -ratio;
            vel.x = vel.x * -1.0;

        }
        else if (loc.x >= ratio)
        {
            loc.x = ratio;
            vel.x = vel.x * -1.0;

        }
        if ( loc.y <= -1  )
        {
            //NSLog(@"hit a wall, changing y velocity");
            loc.y = -1;
            vel.y = vel.y * -1.0;
        }
        else if (loc.y >= 1)
        {
            loc.y = 1;
            vel.y = vel.y * -1.0;
        }
    }
    
    if ( fadeOut )
    {
        sca.x += inc;
        sca.y += inc;
        sca.z += inc;
        alpha -= 2*dt;
        
        // check for termination condition
        if( alpha < .01 )
        {
            active = false;
        }

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




String::String(Vector3D *a, Vector3D *b, float start_freq, float halfWidth)
{
    stringVertices[0] = a->x;
    stringVertices[1] = a->y;
    stringVertices[2] = b->x;
    stringVertices[3] = b->y;
    
    float multiplier = 0.25;
    stringRectVertices[0] = a->x;
    stringRectVertices[1] = a->y - halfWidth*multiplier;
    stringRectVertices[2] = a->x;
    stringRectVertices[3] = a->y + halfWidth*multiplier;
    stringRectVertices[4] = b->x;
    stringRectVertices[5] = b->y - halfWidth*multiplier;
    stringRectVertices[6] = b->x;
    stringRectVertices[7] = b->y + halfWidth*multiplier;
  
    

    NSLog(@"creating a string");
}


void String::update( double dt )
{
    // pass
}



void String::render()
{
    // enable blending
    glEnable( GL_BLEND );
    // set blend func
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    // glBlendFunc( GL_ONE, GL_ONE );
    glLineWidth(1.0);
    
    
    
    // vertex
    glVertexPointer( 2, GL_FLOAT, 0, stringRectVertices );
    glEnableClientState( GL_VERTEX_ARRAY );
    
    // line strip
    //glDrawArrays( GL_LINE_STRIP, 0, 2);

    glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
    
    
    // disable blend
    glDisable( GL_BLEND );
}

void String::setPointA(GLfloat x, GLfloat y)
{
    stringVertices[0] = x;
    stringVertices[1] = y;
}


void String::setPointB(GLfloat x, GLfloat y)
{
    stringVertices[4] = x;
    stringVertices[5] = y;
}


void Sphere::update( double dt )
{
    // interp
    size.interp( dt );
    
    // update!
    GLfloat inc = .5 * dt;
//    sca.x += inc;
//    sca.y += inc;
//    sca.z += inc;
//    alpha -= 2*dt;
//    
//    // check for termination condition
//    if( alpha < .01 )
//    {
//        active = false;
//    }

    GLfloat g_gfxWidth = 1024;
    GLfloat g_gfxHeight = 640;
    GLfloat ratio = g_gfxWidth / g_gfxHeight;
    if (isMoving)
    {
        loc.set(loc.x + dt*vel.x, + loc.y + dt*vel.y, loc.z + dt*vel.z);
        //NSLog(@"loc.x is: %f and loc.y is: %f", loc.x, loc.y);
        if ( loc.x <= -ratio || loc.x >= ratio)
        {
            //NSLog(@"hit a wall, changing x velocity");
            vel.x = vel.x * -1.0;
            // TODO: make some freaking sound!
            
        }
        
        if ( loc.y <= -1 || loc.y >= 1 )
        {
            //NSLog(@"hit a wall, changing y velocity");
            
            // TODO:make some freaking sound
            vel.y = vel.y * -1.0;
        }
    }

}

void Sphere::render()
{
    // render
    glutSolidSphere( size.value, slices, stacks );
}






