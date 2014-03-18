//
//  Globals.h
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#ifndef __SoundRunner__Globals__
#define __SoundRunner__Globals__

#import <iostream>
#import "mo_gfx.h"
#import "Entity.h"

//----------------------------------------------------------------
// name: class Globals
// desc: the global class
//----------------------------------------------------------------
class Globals
{
public:
    static GLuint g_texture[3];
    // default BPM
    static float BPM;
    static GLfloat leftBound;
    static GLfloat rightBound;
    
};


#endif /* defined(__SoundRunner__Globals__) */
