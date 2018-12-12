//
//  ZLHttpRequestManager.h
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/11/9.
//  Copyright © 2018 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZLSTSInfoModel.h"
#import "LBService.h"

typedef void(^ LBRequestSuccessDataBlock) (NSDictionary *data);
typedef void(^ LBRequestSuccessBoolBlock) (BOOL success);
typedef void(^ LBRequestFailBlock) (NSString *message);

@interface ZLHttpRequestManager : NSObject

/**
 清理会话消息未读数

 @param sId 会话ID
 @param success success description
 @param fail fail description
 */
+ (void)cleanSessionMsgWithSId:(NSString *)sId
                       success:(LBRequestSuccessDataBlock)success
                          fail:(LBRequestFailBlock)fail;


/**
 获取会话消息未读数

 @param sId 会话ID
 @param success success description
 @param fail fail description
 */
+ (void)getSessionMsgCountWithSId:(NSString *)sId
                          success:(LBRequestSuccessDataBlock)success
                             fail:(LBRequestFailBlock)fail;
/**
 OSS上传图片之前请求服务器获取OSS服务器配置参数
 
 @param fileType fileType description
 @param success success description
 @param fail fail description
 */
+ (void)getSTSInfoWithFileType:(NSString *)fileType
                       success:(LBRequestSuccessDataBlock)success
                          fail:(LBRequestFailBlock)fail;

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
                           fail:(LBRequestFailBlock)fail;
/**
 STS授权(已废弃)
 
 @param success success description
 @param fail fail description
 */
+ (void)getSTSAuthorizeWithFileType:(NSString *)fileType
                            Success:(LBRequestSuccessDataBlock)success
                               fail:(LBRequestFailBlock)fail;
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
                            fail:(LBRequestFailBlock)fail;
/**
 获取会话信息
 
 @param sId appId description
 @param success success description
 @param fail fail description
 */
+ (void)getSessionInfoWithSId:(NSString *)sId
                      success:(LBRequestSuccessDataBlock)success
                         fail:(LBRequestFailBlock)fail;
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
                                fail:(LBRequestFailBlock)fail;

//图片上传到OSS获取fileName
//fileName并不是完整的文件地址  要通过“getObjectUrlWithFileType”这个方法去取完整的文件地址
+ (void)zl_updateToOSSWithdata:(NSData *)data
                   contentType:(NSString *)contentType
                       success:(void(^)(NSString *fileName))resultSucccess
                          fail:(void(^)(NSString *message))fail;


@end

