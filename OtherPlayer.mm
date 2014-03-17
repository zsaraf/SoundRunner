//
//  OtherPlayer.m
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "OtherPlayer.h"

@implementation OtherPlayer

-(id)initWithName:(NSString *)name
{
    if (self = [super init]) {
        NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GeneralUser_GS_FluidSynth_v1" ofType:@"sf2"]];
        self.soundGen = [[SoundGen alloc] initWithSoundFontURL:presetURL patchNumber:2];
        self.xLoc = 0;
        self.noteOn = NO;
        self.name = name;
        self.avatar = NULL;
    }
    return self;
}

@end
