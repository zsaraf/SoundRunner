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


// TODO: initialize this object to hold all the correct instruments. make sure the property

- (id) init {
    self = [super init];
    // init the mutable array
    
    self.instruments = [NSMutableArray new];
    
    // make an instrument
    Instrument *bariSax = [self addInstrWithBankNum:0 patchNum:67 atIndex:0];
    Instrument *squareLead2 = [self addInstrWithBankNum:12 patchNum:80 atIndex:1];
    Instrument *chorusedFM = [self addInstrWithBankNum:8 patchNum:5 atIndex:2];
    // insert it.
    
    return self;
}

- (Instrument *)addInstrWithBankNum:(int)bankNum patchNum:(int)patchNum atIndex:(int)index
{
    Instrument *thisInstr = [[Instrument alloc] init];
    thisInstr.bankNum = bankNum;
    thisInstr.patchNum = patchNum;
    // add to array
    [self.instruments insertObject:thisInstr atIndex:index];
    return thisInstr;
}


@end
