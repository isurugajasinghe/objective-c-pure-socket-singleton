//
//  MySocketSingleton.m
//  TestSocket
//
//  Created by Epic Lanka on 3/31/18.
//  Copyright © 2018 Epic Lanka. All rights reserved.
//

#import "MySocketSingleton.h"

@interface MySocketSingleton()<NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSMutableArray *messages;

@end

static MySocketSingleton *_sharedGlobals;

@implementation MySocketSingleton

+ (MySocketSingleton *)sharedGlobals {
    @synchronized(self) {
        if (_sharedGlobals == nil) {
            _sharedGlobals = [[super allocWithZone:NULL] init];
        }
    }
    return _sharedGlobals;
}


+(void)initNetworkCommunicationUrl:(NSString*)serveripString port:(UInt32)port {
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)serveripString, port, &readStream, &writeStream);
    
    [MySocketSingleton sharedGlobals].inputStream = (__bridge NSInputStream *)readStream;
    [MySocketSingleton sharedGlobals].outputStream = (__bridge NSOutputStream *)writeStream;
    [[MySocketSingleton sharedGlobals].inputStream setDelegate:[MySocketSingleton sharedGlobals]];
    [[MySocketSingleton sharedGlobals].outputStream setDelegate:[MySocketSingleton sharedGlobals]];
    [[MySocketSingleton sharedGlobals].inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[MySocketSingleton sharedGlobals].outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[MySocketSingleton sharedGlobals].inputStream open];
    [[MySocketSingleton sharedGlobals].outputStream open];
}

+(void)sendString:(NSString*)message {
    NSString *response  = message;
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
    [[MySocketSingleton sharedGlobals].outputStream write:[data bytes] maxLength:[data length]];
}

- (void)messageReceived:(NSString *)message {
    
    [self.messages addObject:message];
    if (self.delegate && [_delegate respondsToSelector:@selector(something:)]){
        [_delegate something:message];
    }

    NSLog(@"message Received : %@",message);
}

#pragma mark stream delegate
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"stream event %lu", (unsigned long)streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened");
            break;
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == self.inputStream) {
                
                uint8_t buffer[1024];
                NSUInteger len;
                
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
                        
                        if (nil != output) {
                            
                            NSLog(@"server said: %@", output);
                            [self messageReceived:output];
                            
                        }
                    }
                }
            }
            break;
            
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"Can not connect to the host");
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            theStream = nil;
            
            break;
        default:
            NSLog(@"Unknown event");
    }
    
}


@end
