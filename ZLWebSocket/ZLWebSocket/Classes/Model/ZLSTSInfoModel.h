//
//  ZLSTSInfoModel.h
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/9.
//  Copyright © 2018 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZLSTSInfoModel : NSObject

@property (nonatomic, strong) NSString *accessKeySecret;

@property (nonatomic, strong) NSString *accessKeyId;

@property (nonatomic, strong) NSString *securityToken;

@property (nonatomic, strong) NSString *bucket;

@property (nonatomic, strong) NSString *dir;

@property (nonatomic, strong) NSString *endpoint;

@property (nonatomic, strong) NSString *expiration;//过期时间
@end


