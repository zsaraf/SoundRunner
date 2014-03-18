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
    self.instruments = [NSMutableArray new];
    Instrument *bariSax = [[Instrument alloc] init];
    if (bariSax)
    {
        NSLog(@"bari made!");
    }
    bariSax.bankNum = 0;
    bariSax.patchNum = 67;
    [self.instruments insertObject:bariSax atIndex:0];
    return self;
}
@end
