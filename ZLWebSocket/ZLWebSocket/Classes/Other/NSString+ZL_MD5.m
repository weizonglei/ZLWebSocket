//
//  NSString+ZL_MD5.m
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/10.
//  Copyright © 2018 wzl. All rights reserved.
//

#import "NSString+ZL_MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (ZL_MD5)
#pragma mark - 32位 小写
+(NSString *)MD5ForLower32Bate:(NSString *)str{
    
    //要进行UTF8的转码
    const char* input = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input, (CC_LONG)strlen(input), result);
    
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    
    return digest;
}
@end
