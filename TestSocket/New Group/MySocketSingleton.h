//
//  MySocketSingleton.h
//  TestSocket
//
//  Created by Epic Lanka on 3/31/18.
//  Copyright © 2018 Epic Lanka. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SomethingDelegate <NSObject>
@optional
- (void)something:(NSString*)something;

@end

@interface MySocketSingleton : NSObject

@property (nonatomic, weak) id <SomethingDelegate> delegate;

+ (MySocketSingleton*)sharedGlobals;

+ (void)initNetworkCommunicationUrl:(NSString*)serveripString port:(UInt32)port;
+(void)sendString:(NSString*)message;

@end
