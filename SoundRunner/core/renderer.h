//
//  renderer.h
//  SoundRunner
//
//  Created by JP Wright on 2/26/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#ifndef __SoundRunner__renderer__
#define __SoundRunner__renderer__

#include <iostream>
#import <vector>
#import "mo_audio.h"
#import "mo_touch.h"
#import "mo_gfx.h"



// initialize the engine (audio, grx, interaction)
void RunnerInit();
// set graphics dimensions
void RunnerSetDims( GLfloat width, GLfloat height );
// draw next frame of graphics
void RunnerRender();



#endif /* defined(__SoundRunner__renderer__) */
