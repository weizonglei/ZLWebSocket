//
//  ZLToken.m
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/10.
//  Copyright © 2018 wzl. All rights reserved.
//

#import "ZLToken.h"

@implementation ZLToken
+ (instancetype)sharedManager
{
    static __kindof ZLToken *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance=[[super allocWithZone:NULL] init];
    });
    return sharedInstance;
}
+ (void)load{
    [super load];
    
}
@end
