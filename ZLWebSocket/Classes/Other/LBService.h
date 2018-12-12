//
//  LBService.h
//  LJBiddingPlatform
//
//  Created by Fanxx on 16/1/13.
//  Copyright © 2016年 Do1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/OSSService.h>
#import <UIKit/UIKit.h>

@class LBResponse;

/**
 *	请求参数编码
 */
typedef enum : NSUInteger{
    LBRequestParameterEncodingURL = 0,
    LBRequestParameterEncodingURLEncodedInURL,
    LBRequestParameterEncodingJSON,
} LBRequestParameterEncoding;

typedef NS_ENUM(NSInteger,LBRespondStatusCode) {
    //需要登录或者Token已经过期的响应
    LBRespondStatusCodeNeedLogin = 0001,
    //普通错误的响应
    LBRespondStatusCodeError = 0003,
    //成功的响应
    LBRespondStatusCodeSuccess = 0000,
    //需要使用图形验证码的响应
    LBRespondStatusCodeNeedVerifyImage = 1101, 
    //网络未连接的响应
    LBRespondStatusCodeNoNetWork = 10086,
};

typedef void(^ LBRequestSuccessDataBlock) (NSDictionary *data);
typedef void(^ LBRequestSuccessBoolBlock) (BOOL success);
typedef void(^ LBRequestFailBlock) (NSString *message);

/**
 *	接口请求
 */
@interface LBRequest : NSObject
@property (strong,nonatomic) NSString *path;
@property (strong,nonatomic) NSString *method;
@property (assign,nonatomic) LBRequestParameterEncoding encoding;
@property (strong,nonatomic) NSDictionary<NSString*,id> *params;
@property (strong,nonatomic) void(^completion)(LBResponse*);
@end
/**
 *  上传请求
 */
@interface LBUploadRequest : LBRequest
@property (strong,nonatomic) NSData *file;
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *fileName;
@property (strong,nonatomic) NSString *mimeType;
@end
/**
 *  通用的json请求
 */
@interface LBUniversalRequest : LBRequest
@end

/**
 *	@brief	请求响应
 */
@interface LBResponse : NSObject
@property (strong,nonatomic) LBRequest *request;
@property (assign,nonatomic) NSInteger resultCode;
@property (strong,nonatomic) NSString *message;
@property (assign,nonatomic) BOOL succeed;
@property (strong,nonatomic) id data;
@property (strong,nonatomic) NSDictionary<NSString*,id> *result;
@end

@interface LBService : NSObject

@property (nonatomic, strong) NSString *token;

/**
 *  检查返回的数据
 *
 *  @param check 是否检查
 */
+(void)setResponseCheck:(BOOL(^)(LBResponse*))check;
/**
 *  暂停接口的调用(可保证在调用goon之前的请求不会执行，但会执行下一个调用pause的请求)
 *
 *  @param request 请求
 */
+(void)pause:(LBRequest*)request;
/**
 *  继续调用(调用后先调用参数指定的请求，再继续调用之前被暂停的请求)
 *
 *  @param request 请求
 */
+(void)goon:(LBRequest*)request;
/**
 *  请求接口
 *
 *  @param request 请求
 */
+(void)request:(LBRequest*)request;
/**
 *  请求接口
 *
 *  @param path       URL路径
 *  @param method     方法
 *  @param params     参数
 *  @param completion 回调
 */
+(void)request:(NSString *)path
        method:(NSString*)method
        params:(NSDictionary<NSString*,id>*)params
    completion:(void(^)(LBResponse*))completion;
/**
 *  GET请求
 *
 *  @param path       URL路径
 *  @param params     参数
 *  @param completion 回调
 */
+(void)get:(NSString*)path
    params:(NSDictionary<NSString*,id>*)params
completion:(void(^)(LBResponse* response))completion;
/**
 *  POST请求
 *
 *  @param path       URL路径
 *  @param params     参数
 *  @param completion 回调
 */
+(void)post:(NSString*)path
     params:(NSDictionary<NSString*,id>*)params
 completion:(void(^)(LBResponse* response))completion;
/**
 *  get请求接口
 *
 *  @param path       URL路径
 *  @param params     参数
 *  @param completion 回调
 *  @param universal  是否通用
 */
+(void)get:(NSString *)path
    params:(NSDictionary<NSString *,id> *)params
completion:(void (^)(id json))completion
 universal:(BOOL)universal;
/**
 *  post请求接口
 *
 *  @param path       URL路径
 *  @param params     参数
 *  @param completion 回调
 *  @param universal  是否通用
 */
+(void)post:(NSString *)path
     params:(NSDictionary<NSString *,id> *)params
 completion:(void (^)(id json))completion
  universal:(BOOL)universal;
/**
 *  上传请求
 *
 *  @param path       URL路径
 *  @param file       文件
 *  @param name       名字
 *  @param fileName   文件名字
 *  @param mimeType   类型
 *  @param params     参数
 *  @param completion 回调
 */
+(void)upload:(NSString*)path
         file:(NSData*)file
         name:(NSString*)name
     fileName:(NSString*)fileName
     mimeType:(NSString*)mimeType
       params:(NSDictionary<NSString*,id>*)params
   completion:(void(^)(LBResponse* response))completion;
/**
 *  上传请求
 *
 *  @param path       URL路径
 *  @param file       文件
 *  @param name       名字
 *  @param params     参数
 *  @param completion 回调
 */
+(void)upload:(NSString*)path
         file:(NSData*)file
         name:(NSString*)name
       params:(NSDictionary<NSString*,id>*)params
   completion:(void(^)(LBResponse* response))completion;
/**
 *  下载图形验证码
 *
 *  @param path       URL路径
 *  @param params     参数
 *  @param completion 下载成功回调
 *  @param failure    下载失败回调
 */
+(void)downImage:(NSString*)path
          params:(NSDictionary<NSString*,id>*)params
      completion:(void(^)(id   responseObject))completion
         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;



@end
