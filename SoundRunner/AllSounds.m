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
    [self addInstrWithName:@"Stereo Grand" color:[UIColor orangeColor] bankNum:0 patchNum:0 atIndex:0];
    [self addInstrWithName:@"Baritone Sax" color:[UIColor whiteColor] bankNum:0 patchNum:67 atIndex:1];
    [self addInstrWithName:@"Square Lead 2" color:[UIColor redColor] bankNum:12 patchNum:80 atIndex:2];
    [self addInstrWithName:@"Chorused FM" color:[UIColor greenColor] bankNum:8 patchNum:5 atIndex:3];
    [self addInstrWithName:@"Polysynth" color:[UIColor magentaColor] bankNum:0 patchNum:90 atIndex:4];
    [self addInstrWithName:@"Formant Synth" color:[UIColor blueColor] bankNum:8 patchNum:26 atIndex:5];
    [self addInstrWithName:@"Orchestra Pad" color:[UIColor purpleColor] bankNum:8 patchNum:48 atIndex:6];
    [self addInstrWithName:@"Synth Mallet" color:[UIColor cyanColor] bankNum:1 patchNum:98 atIndex:7];
    
    
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
