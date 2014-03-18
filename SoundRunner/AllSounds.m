//
//  AllSounds.m
//  SoundRunner
//
//  Created by JP Wright on 3/17/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import "AllSounds.h"
#import "Instrument.h"
//#import "mo_gfx.h"

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
    Instrument *bariSax = [self addInstrWithName:@"Baritone Sax "bankNum:0 patchNum:67 atIndex:0];
    Instrument *squareLead2 = [self addInstrWithName:@"Square Lead 2" bankNum:12 patchNum:80 atIndex:1];
    Instrument *chorusedFM = [self addInstrWithName:@"Chorused FM" bankNum:8 patchNum:5 atIndex:2];
    
    
    
    return self;
}

- (Instrument *)addInstrWithName:(NSString*)name bankNum:(int)bankNum patchNum:(int)patchNum  atIndex:(int)index // andColor:(Vector3D)color
{
    Instrument *thisInstr = [[Instrument alloc] init];
    thisInstr.name = name;
    thisInstr.bankNum = bankNum;
    thisInstr.patchNum = patchNum;
//    thisInstr.color = color;
    // add to array
    [self.instruments insertObject:thisInstr atIndex:index];
    return thisInstr;
}


@end
