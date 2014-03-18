//
//  SoundGen.h
//  SoundRunner
//
//  Created by Zachary Waleed Saraf on 3/1/14.
//  Copyright (c) 2014 Zachary Waleed Saraf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SoundGen : NSObject <AVAudioSessionDelegate>

-(id)initWithSoundFontURL:(NSURL *)soundFontURL bankNumber:(uint8_t)bankNumber patchNumber:(NSInteger)patchNumber;
-(void)playMidiNote:(NSInteger)note velocity:(NSInteger)velocity;
-(void)stopPlayingMidiNote:(NSInteger)note;
-(void)stopPlayingAllNotes;
-(void)setBankNumber:(uint8_t)bankNumber patchNumber:(NSInteger)patchNumber;

@property (nonatomic, strong) NSURL *soundFontURL;
@property (nonatomic) NSInteger patchNumber;
@property (nonatomic) uint8_t bankNumber;

@end
