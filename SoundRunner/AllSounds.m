//
//  AllSounds.m
//  SoundRunner
//
//  Created by JP Wright on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "AllSounds.h"
#import "Instrument.h"

@implementation AllSounds
@synthesize instruments;
- (Instrument *)getInstrumentAtIndex:(int)index
{
    return [self.instruments objectAtIndex:index];
}



+(AllSounds *)instance
{
    static AllSounds *allSounds = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allSounds = [[self alloc] init];
    });
    return allSounds;
}

// TODO: initialize this object to hold all the correct instruments. make sure the property

- (id) init {
    self = [super init];
    // init the mutable array
    
    self.instruments = [NSMutableArray new];
    
    // add all the instruments!
    [self addInstrWithName:@"Stereo Grand" color:[UIColor colorWithRed:97/255. green:181/255. blue:191/255. alpha:0.4] bankNum:0 patchNum:0 atIndex:0];
    [self addInstrWithName:@"Chorused FM" color:[UIColor colorWithRed:165/255. green:213/255. blue:232/255. alpha:0.4] bankNum:8 patchNum:5 atIndex:1];
    [self addInstrWithName:@"Polysynth" color:[UIColor colorWithRed:245/255. green:92/255. blue:88/255. alpha:0.4] bankNum:0 patchNum:90 atIndex:2];
    [self addInstrWithName:@"Formant Synth" color:[UIColor colorWithRed:217/255. green:72/255. blue:36. alpha:0.4   ] bankNum:8 patchNum:26 atIndex:3];
    [self addInstrWithName:@"Orchestra Pad" color:[UIColor colorWithRed:121/255. green:157/255. blue:214/255. alpha:0.4] bankNum:8 patchNum:48 atIndex:4];
    [self addInstrWithName:@"Synth Mallet" color:[UIColor colorWithRed:1.0 green:0.756 blue:0.756 alpha:0.4] bankNum:1 patchNum:98 atIndex:5];
    
    
    return self;
}

-(Instrument *)instrumentForName:(NSString *)name
{
    for (Instrument *instrument in self.instruments) {
        if ([instrument.name isEqualToString:name]) {
            return instrument;
        }
    }
    return nil;
}

- (Instrument *)addInstrWithName:(NSString*)name color:(UIColor*)color bankNum:(int)bankNum patchNum:(int)patchNum atIndex:(int)index
{
    Instrument *thisInstr = [[Instrument alloc] init];
    thisInstr.name = name;
    thisInstr.bankNum = bankNum;
    thisInstr.patchNum = patchNum;
    thisInstr.color = color;
    // add to array
    [self.instruments insertObject:thisInstr atIndex:index];
    return thisInstr;
}


@end
