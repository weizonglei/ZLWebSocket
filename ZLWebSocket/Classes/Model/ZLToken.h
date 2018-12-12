//
//  ZLToken.h
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/10.
//  Copyright © 2018 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZLToken : NSObject
/**
 *  用户Token
 */
@property(nonatomic , copy)NSString *token;
+ (instancetype)sharedManager;
@end
