//
//  ZLHttpRequestManager.m
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/9.
//  Copyright © 2018 wzl. All rights reserved.
//

#import "ZLHttpRequestManager.h"
#import <MJExtension/MJExtension.h>
#import "NSString+ZL_MD5.h"

//#define URL_Header @"http://imapi.zsoho.vip/"

#define URL_Header @"http://192.168.50.42:8089"


@implementation ZLHttpRequestManager

/**
 清理会话消息未读数
 
 @param sId 会话ID
 @param success success description
 @param fail fail description
 */
+ (void)cleanSessionMsgWithSId:(NSString *)sId
                       success:(LBRequestSuccessDataBlock)success
                          fail:(LBRequestFailBlock)fail{
    NSDictionary * dic = @{
                           @"sId":sId
                           };
    
    [LBService get:[NSString stringWithFormat:@"%@/imsession/cleanSessionMsg",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}


/**
 获取会话消息未读数
 
 @param sId 会话ID
 @param success success description
 @param fail fail description
 */
+ (void)getSessionMsgCountWithSId:(NSString *)sId
                          success:(LBRequestSuccessDataBlock)success
                             fail:(LBRequestFailBlock)fail{
    NSDictionary * dic = @{
                           @"sId":sId
                           };
    
    [LBService get:[NSString stringWithFormat:@"%@/imsession/getSessionMsgCount",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}
/**
 OSS上传图片之前请求服务器获取OSS服务器配置参数
 
 @param fileType fileType description
 @param success success description
 @param fail fail description
 */
+ (void)getSTSInfoWithFileType:(NSString *)fileType
                       success:(LBRequestSuccessDataBlock)success
                          fail:(LBRequestFailBlock)fail{
    NSDictionary * dic = @{
                           @"fileType":fileType
                           };
    
    [LBService post:[NSString stringWithFormat:@"%@/sts/token",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}

/**
 获取历史消息列表

 @param sId 会话id
 @param pageNo 页码
 @param pageSize 每页大小
 @param toUserId 接收用户Id
 @param empSId 客服会话记录
 @param fromUserId 发送用户ID
 @param success success description
 @param fail fail description
 */
+ (void)getImMessageListWithSId:(NSString *)sId
                         pageNo:(NSString *)pageNo
                       pageSize:(NSString *)pageSize
                       toUserId:(NSString *)toUserId
                         empSId:(NSString *)empSId
                     fromUserId:(NSString *)fromUserId
                        success:(LBRequestSuccessDataBlock)success
                           fail:(LBRequestFailBlock)fail{
    NSDictionary *dic = @{
                          @"sId":sId,
                          @"toUserId":toUserId,
                          @"empSId":empSId,
                          @"pageNo":pageNo,
                          @"pageSize":pageSize,
                          @"fromUserId":fromUserId
                          };
    [LBService get:[NSString stringWithFormat:@"%@/msg/getImMessageList",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}

/**
 STS授权
 
 @param success success description
 @param fail fail description
 */
+ (void)getSTSAuthorizeWithFileType:(NSString *)fileType
                            Success:(LBRequestSuccessDataBlock)success
                               fail:(LBRequestFailBlock)fail{
    NSDictionary *dic = @{
                          @"fileType":fileType
                          };
    [LBService get:[NSString stringWithFormat:@"%@/sts/policy",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}
/**
 获取oss文件对象的全路径ObjectUrl
 
 @param fileType fileType description
 @param height height description
 @param key key description
 @param width width description
 @param success success description
 @param fail fail description
 */
+ (void)getObjectUrlWithFileType:(NSString *)fileType
                          height:(NSString *)height
                             key:(NSString *)key
                           width:(NSString *)width
                         success:(LBRequestSuccessDataBlock)success
                            fail:(LBRequestFailBlock)fail{
    NSDictionary *dic = @{
                          @"fileType":fileType,
                          @"height":height,
                          @"key":key,
                          @"width":width
                          };
    [LBService post:[NSString stringWithFormat:@"%@/sts/getObjectUrl",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}
/**
 获取会话信息
 
 @param sId appId
 @param success success description
 @param fail fail description
 */
+ (void)getSessionInfoWithSId:(NSString *)sId
                      success:(LBRequestSuccessDataBlock)success
                         fail:(LBRequestFailBlock)fail{
    NSDictionary *dic = @{
                          @"sId":sId,
                          };
    [LBService get:[NSString stringWithFormat:@"%@/imsession/getSessionInfo",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}

/**
 获取会话列表

 @param pageNo pageNo description
 @param pageSize pageSize description
 @param success success description
 @param fail fail description
 */
+ (void)getUserSessionListWithPageNo:(NSString *)pageNo
                            pageSize:(NSString *)pageSize
                             success:(LBRequestSuccessDataBlock)success
                                fail:(LBRequestFailBlock)fail{
    NSDictionary *dic = @{
                          @"pageNo":pageNo,
                          @"pageSize":pageSize
                          };
    [LBService get:[NSString stringWithFormat:@"%@/imsession/getUserSessionList",URL_Header] params:dic completion:^(LBResponse *response) {
        if (response.succeed) {
            success(response.data);
        }
        else {
            fail(response.message);
        }
    }];
}


+ (void)zl_updateToOSSWithdata:(NSData *)data
                   contentType:(NSString *)contentType
                       success:(void(^)(NSString *fileName))updateSucccess
                          fail:(void(^)(NSString *message))updateFail{
    NSData *fielData = data;
    NSString *endpoint = @"https://oss-cn-shenzhen.aliyuncs.com";
    //从服务端获取token
    [ZLHttpRequestManager getSTSInfoWithFileType:@"-1" success:^(NSDictionary *data) {
        ZLSTSInfoModel *model = [ZLSTSInfoModel new];
        model = [ZLSTSInfoModel mj_objectWithKeyValues:data];
        if (model) {
            NSString *objectKey = [NSString MD5ForLower32Bate:[NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSinceNow:0]]];
            id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:model.accessKeyId secretKeyId:model.accessKeySecret securityToken:model.securityToken];
            
            OSSClientConfiguration * conf = [OSSClientConfiguration new];
            conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
            conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
            conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
            
            OSSClient * client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
            
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            put.bucketName = model.bucket;
            put.objectKey = objectKey;
            put.contentType = contentType;
            
            put.uploadingData = fielData;
            
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                
            };
            
            OSSTask * putTask = [client putObject:put];
            
            [putTask continueWithBlock:^id(OSSTask *task) {
                
                task = [client presignPublicURLWithBucketName:model.bucket
                                                withObjectKey:objectKey];
                if (!task.error) {
                    OSSAppendObjectResult * result = task.result;
                    updateSucccess([NSString stringWithFormat:@"%@",result]);
                    NSLog(@"上传成功");
                } else {
                    updateFail([NSString stringWithFormat:@"%@",task.error]);
                    NSLog(@"上传失败");
                }
                return nil;
            }];
        }
    } fail:^(NSString *message) {
        NSLog(@"从服务器获取OSS Token失败");
    }];

}

@end
