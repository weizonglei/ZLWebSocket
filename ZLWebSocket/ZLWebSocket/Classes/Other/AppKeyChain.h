//
//  AppKeyChain.h
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/7.
//  Copyright © 2018 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppKeyChain : NSObject

+ (void)saveData:(id)data forKey:(NSString *)key;

+ (id)loadForKey:(NSString *)key;

+ (void)deleteKeyData:(NSString *)key;

@end

