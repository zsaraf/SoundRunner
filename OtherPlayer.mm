//
//  OtherPlayer.m
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "OtherPlayer.h"

@implementation OtherPlayer

@synthesize instrument = _instrument;

-(id)initWithName:(NSString *)name
{
    if (self = [super init]) {
        NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GeneralUser_GS_FluidSynth_v1" ofType:@"sf2"]];
        self.soundGen = [[SoundGen alloc] initWithSoundFontURL:presetURL bankNumber:0 patchNumber:2];
        self.xLoc = 0;
        self.noteOn = NO;
        self.name = name;
        self.avatar = NULL;
    }
    return self;
}

-(void)setInstrument:(Instrument *)instrument
{
    _instrument = instrument;
    
    if (self.avatar) {
        const float* colors = CGColorGetComponents( instrument.color.CGColor );
        self.avatar->col = Vector3D(colors[0], colors[1], colors[2]);
    }
    
    [self.soundGen setBankNumber:instrument.bankNum patchNumber:instrument.patchNum];
}

@end
