//
//  Drummer.m
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "Drummer.h"

#define KICK 35
#define SNARE 37
#define CLAP 39
#define CYMBAL1 42
#define CYMBAL2 44

@interface Drummer ()

@property (nonatomic) NSInteger t;

@end

@implementation Drummer

-(id)init
{
    if (self = [super init]) {
        NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"GeneralUser_GS_FluidSynth_v1" ofType:@"sf2"]];
        self.soundGen = [[SoundGen alloc] initWithSoundFontURL:presetURL bankNumber:120 patchNumber:24];
    }
    return self;
}

-(void)tick
{
    [self.soundGen stopPlayingAllNotes];
    //[self.soundGen playMidiNote:CYMBAL velocity:127];
    if (self.t % 8 == 0 || self.t % 16 == 7 || self.t % 16 == 3 || self.t % 16 == 11) {
        [self.soundGen playMidiNote:KICK velocity:127];
    } else if (self.t % 8 == 4) {
        [self.soundGen playMidiNote:SNARE velocity:127];
        [self.soundGen playMidiNote:CLAP velocity:127];
    }
    
    if (self.t % 2 == 0) {
        [self.soundGen playMidiNote:CYMBAL1 velocity:127];
    }
//    } else if (self.t % 2 == 1) {
//        [self.soundGen playMidiNote:CYMBAL2 velocity:127];
//    }
    
    self.t ++;
}


@end
