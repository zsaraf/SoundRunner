//
//  NetworkManager.m
//  lovestep
//
//  Created by Zachary Waleed Saraf on 11/13/13.
//  Copyright (c) 2013 Zachary Waleed Saraf. All rights reserved.
//

#import "NetworkManager.h"
#import "OtherPlayer.h"
#import "SoundRunnerUtil.h"
#import "AllSounds.h"

#define WAITING_FOR_OTHER_USER_TAG 20
#define USER_NAME_SEND_TAG 21
#define USER_NAME_RECEIVE_TAG 22
#define RECEIVED_ARRAY 23
#define HEADER_TAG 24
#define RECEIVED_DISABLE 25
#define RECEIVED_ENABLE 26


#define LOOP_TYPE 1
#define ENABLE_TYPE 2
#define DISABLE_TYPE 3

@interface NetworkManager ()

@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;

@end

@implementation NetworkManager

static NetworkManager *myInstance;

//singleton
+(NetworkManager *)instance
{
    @synchronized(self)
    {
        if (myInstance == NULL)
            myInstance = [[self alloc] init];
    }
    
    return(myInstance);
}

-(void)createNetwork
{
    if (self.asyncSocket) return;
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.asyncSocket connectToHost:@"192.168.187.187" onPort:80 error:nil];
    [self.asyncSocket readDataWithTimeout:-1 tag:WAITING_FOR_OTHER_USER_TAG];
    [[NSNumber numberWithInt:5] intValue];
}

-(void)sendNewPlayerMessage:(NSString *)newPlayer
{
    NSString *newPlayerString = [NSString stringWithFormat:@"NEWPLAYER:%@:%@:", newPlayer, [SoundRunnerUtil appDelegate].currentInstrument.name];
    NSData *data = [newPlayerString dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:data withTimeout:-1 tag:1];
    [self.asyncSocket readDataWithTimeout:-1 tag:2];
}

-(void)sendNoteOn:(BOOL)noteOn
{
    NSString *dataString = [NSString stringWithFormat:@"CHANGENOTEON:%d:", noteOn];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:data withTimeout:-1 tag:1];
    [self.asyncSocket readDataWithTimeout:-1 tag:2];
}

-(void)sendChangeInstrument:(Instrument *)instrument
{
    NSString *dataString = [NSString stringWithFormat:@"CHANGEINSTRUMENT:%@:", instrument.name];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:data withTimeout:-1 tag:1];
    [self.asyncSocket readDataWithTimeout:-1 tag:2];
}

-(void)sendChangeXLoc:(CGFloat)xLoc
{
    NSString *dataString = [NSString stringWithFormat:@"CHANGEXLOC:%f:", xLoc];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:data withTimeout:-1 tag:1];
    [self.asyncSocket readDataWithTimeout:-1 tag:2];
}

#pragma delegate methods
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    const void *bytes = [data bytes];
    char buff[data.length + 1];
    memcpy(buff, bytes, data.length);
    buff[data.length] = '\0';
    NSString *dataString = [NSString stringWithUTF8String:buff];
    NSLog(@"RECEIVED: %@", dataString);
    
    NSRange newPlayerRange = [dataString rangeOfString:@"NEWPLAYER:"];
    NSRange otherPlayerRange = [dataString rangeOfString:@"OTHERPLAYERS:"];
    NSRange changeInstrumentRange = [dataString rangeOfString:@"CHANGEINSTRUMENT:"];
    NSRange changeXLocRange = [dataString rangeOfString:@"CHANGEXLOC:"];
    NSRange noteOnRange = [dataString rangeOfString:@"CHANGENOTEON:"];
    if (newPlayerRange.location == 0) {
        NSArray *chunks = [dataString componentsSeparatedByString:@":"];
        NSString *newPlayerName = chunks[1];
        OtherPlayer *newPlayer = [[OtherPlayer alloc] initWithName:newPlayerName];
        newPlayer.instrument = [[AllSounds instance] instrumentForName:chunks[2]];
        [[SoundRunnerUtil appDelegate].otherPlayers setObject:newPlayer forKey:newPlayerName];
    } else if (otherPlayerRange.location == 0) {
        NSArray *chunks = [dataString componentsSeparatedByString:@":"];
        NSLog(@"%@", chunks);
        int numOtherPlayers = (chunks.count - 1)/3;
        for (int i = 0; i < numOtherPlayers; i++) {
            NSString *name = [chunks objectAtIndex:1+3*i];
            Instrument *instrument = [[AllSounds instance] instrumentForName:[chunks objectAtIndex:2+3*i]];
            CGFloat xLoc = [[chunks objectAtIndex:3+3*i] floatValue];
            OtherPlayer *otherPlayer = [[OtherPlayer alloc] initWithName:name];
            otherPlayer.instrument = instrument;
            otherPlayer.xLoc = xLoc;
            [[SoundRunnerUtil appDelegate].otherPlayers setObject:otherPlayer forKey:name];
        }
    } else if (changeInstrumentRange.location == 0) {
        NSArray *chunks = [dataString componentsSeparatedByString:@":"];
        OtherPlayer *otherPlayer = [[SoundRunnerUtil appDelegate].otherPlayers objectForKey:chunks[1]];
        Instrument *instrument = [[AllSounds instance] instrumentForName:[chunks objectAtIndex:2]];
        otherPlayer.instrument = instrument;
    } else if (changeXLocRange.location == 0) {
        NSArray *chunks = [dataString componentsSeparatedByString:@":"];
        OtherPlayer *otherPlayer = [[SoundRunnerUtil appDelegate].otherPlayers objectForKey:chunks[1]];
        CGFloat xLoc = [chunks[2] floatValue];
        otherPlayer.xLoc = xLoc;
        if (otherPlayer.avatar) {
            //otherPlayer.avatar->loc.x = xLoc;
        }
    } else if (noteOnRange.location == 0) {
        NSArray *chunks = [dataString componentsSeparatedByString:@":"];
        OtherPlayer *otherPlayer = [[SoundRunnerUtil appDelegate].otherPlayers objectForKey:chunks[1]];
        BOOL noteOn = [chunks[2] boolValue];
        otherPlayer.noteOn = noteOn;
    }
    
    [self.asyncSocket readDataWithTimeout:-1 tag:HEADER_TAG];
}

@end
