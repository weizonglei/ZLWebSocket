//
//  LBService.m
//  LJBiddingPlatform
//
//  Created by Fanxx on 16/1/13.
//  Copyright © 2016年 Do1. All rights reserved.
//

#import "LBService.h"
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
#import <AdSupport/AdSupport.h>
#import "ZLToken.h"

@implementation LBRequest

@end
@implementation LBUploadRequest

@end
@implementation LBUniversalRequest

@end
@implementation LBResponse

@end

@implementation LBService

static BOOL(^__responseCheck)(LBResponse*) = nil;
+(void)setResponseCheck:(BOOL(^)(LBResponse*))check{
    __responseCheck = check;
}
static  NSArray *__cookies = nil;
+(void)response:(LBRequest*)req json:(NSDictionary*)json{
    
    @try {
        //OSS获取Token的方式有点乱，成功返回的json直接返回，失败的时候走下下面正常
        if ([req isMemberOfClass:[LBUniversalRequest class]]) {
            LBResponse *res = [[LBResponse alloc] init];
            res.request = (LBUniversalRequest*)req ;
            res.data = json;
            if (req.completion) {
                req.completion(res);
            }
            return;
        }
    //正常的流程
    LBResponse *res = [[LBResponse alloc] init];
    res.request = req;
        
    if (json){
        res.result = json;
        res.data = [json valueForKey:@"data"];
        res.message = [json valueForKey:@"msg"];
        if (!res.message) {
            res.message = @"出错了，并且没有错误信息";
        }
        else if ([res.message isEqual:[NSNull null]]){
            res.message = @"";
        }
        if([json valueForKey:@"code"]){
            //防止极端情况下会崩，如服务器返回<null>
            if (![[json valueForKey:@"code"] isEqual:[NSNull null]]) {
                //获取结果码
                res.resultCode = [[json valueForKey:@"code"] integerValue];
                if (res.resultCode == LBRespondStatusCodeNeedLogin) {

                    return;
                    
                }
                else{
                    res.succeed = res.resultCode == LBRespondStatusCodeSuccess;
                    
                }

            }
            else{
                res.resultCode = LBRespondStatusCodeError;
                res.succeed = NO;
            }

        }else{
            res.resultCode = LBRespondStatusCodeError;
            res.succeed = NO;
        }
    }else{
        res.result = nil;
        res.data = nil;
        res.resultCode = LBRespondStatusCodeError;
        res.message = @"网络异常，请检查网络设置";
        res.succeed = NO;
    }
    if (__responseCheck) {
        if (__responseCheck(res)) {
            if (req.completion) {
                req.completion(res);
            }
        }
    }else{
        if (req.completion) {
            req.completion(res);
        }
    }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
static NSMutableArray *__requestQueue;
///暂停接口的调用
+(void)pause:(LBRequest*)request{
    [self request:request ignorePause:YES];
    if (__requestQueue == nil) {
        __requestQueue = [[NSMutableArray alloc] init];
    }
}
///继续调用
+(void)goon:(LBRequest*)request{
    NSMutableArray *reqs = __requestQueue;
    __requestQueue = nil;
    if (request){
        [self request:request];
    }
    if (reqs) {
        for (LBRequest *req in reqs) {
            [self request:req];
        }
    }
}
+(void)request:(LBRequest *)request{
    [self request:request ignorePause:NO];
}
+(void)request:(LBRequest *)request ignorePause:(BOOL)ignorePause{

    if (!ignorePause && __requestQueue) {
        [__requestQueue addObject:request];
        return;
    }
    static AFHTTPSessionManager *manamer;
    if (manamer == nil) {
        manamer = [AFHTTPSessionManager manager];
    }
    NSString *contentType = @"application/json";
    //参数编码
    switch (request.encoding) {
        case LBRequestParameterEncodingURL:
        case LBRequestParameterEncodingURLEncodedInURL:
            if (![manamer.requestSerializer isKindOfClass:[AFHTTPRequestSerializer class]]) {
                manamer.requestSerializer = [AFHTTPRequestSerializer serializer];
                contentType = @"text/html";
            }
            break;
        case LBRequestParameterEncodingJSON:
            if (![manamer.requestSerializer isKindOfClass:[AFJSONRequestSerializer class]]) {
                manamer.requestSerializer = [AFJSONRequestSerializer serializer];
                contentType = @"application/json";
            }
            break;
        default:
            break;
    }
    manamer.requestSerializer.HTTPShouldHandleCookies = YES;
    manamer.requestSerializer.timeoutInterval = 30.0;

    //设置cookies
    if (__cookies) {
        NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:__cookies];
        for (NSString *key in headers.allKeys) {
            [manamer.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    [manamer.requestSerializer setValue:contentType forHTTPHeaderField:@"Accept"];
    //加上charset
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [manamer.requestSerializer setValue:[NSString stringWithFormat:@"%@; charset=%@", contentType,charset] forHTTPHeaderField:@"Content-Type"];
    
    //统一处理Token和Https
    [self setTokenAndHttps:manamer];
    
    AFJSONResponseSerializer *resSer = [AFJSONResponseSerializer serializer];
    resSer.readingOptions = NSJSONReadingMutableLeaves;
    resSer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"text/html",@"text/javascript",@"application/json", nil];
    manamer.responseSerializer = resSer;
    //请求成功
    void(^success)(NSURLSessionDataTask *,id) = ^(NSURLSessionDataTask *task, id responseObject){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"\n收到响应：%zd\n%@\n%@",((NSHTTPURLResponse*)task.response).statusCode,request.path,responseObject);
        // NSLog(@"返回的HeaderFields=%@",((NSHTTPURLResponse*)task.response).allHeaderFields);
        
        ///这个功能只提供给测试人员和开发人员使用
        #if(defined RELEASE_TEST) || (defined DEBUG_TEST) || (defined DEBUG_DEV)
                [self untilTestByRequest:request URLResponse:(NSHTTPURLResponse*)task.response responseData:responseObject errorInfo:nil];
        #endif

        
        //保存token
        if ([[((NSHTTPURLResponse*)task.response).allHeaderFields valueForKey:@"x-token"] length]!=0) {
            [ZLToken sharedManager].token = [((NSHTTPURLResponse*)task.response).allHeaderFields valueForKey:@"x-token"];
            
            NSLog(@"保存的token=%@",[((NSHTTPURLResponse*)task.response).allHeaderFields valueForKey:@"x-token"]);
        }
        
        
        [self response:request json:responseObject];
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:task.currentRequest.URL];
        if (cookies && cookies.count > 0) {
            __cookies = cookies;
        }
    };
    //请求失败
    void(^failure)(NSURLSessionDataTask *, NSError *) = ^(NSURLSessionDataTask *task, NSError *error){
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSLog(@"\n收到失败的响应：%@\n结果：%zd",error.localizedDescription,((NSHTTPURLResponse*)task.response).statusCode);
        ///这个功能只提供给测试人员和开发人员使用
        #if(defined RELEASE_TEST) || (defined DEBUG_TEST) || (defined DEBUG_DEV)
            [self untilTestByRequest:request URLResponse:(NSHTTPURLResponse*)task.response responseData:nil errorInfo:error];
        #endif

        
        [self response:request json:nil];
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:task.currentRequest.URL];
        if (cookies && cookies.count > 0) {
            __cookies = cookies;
        }
    };
    NSLog(@"\n开始请求：\nURL:\t%@\nMethod:\t%@\nParams:\t%@",request.path,request.method,request.params);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if ([request isKindOfClass:[LBUploadRequest class]]) {
        LBUploadRequest *uploadReqeust = (LBUploadRequest*)request;
        [manamer POST:request.path parameters:request.params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (uploadReqeust.mimeType) {
                [formData appendPartWithFileData:uploadReqeust.file name:uploadReqeust.name fileName:uploadReqeust.fileName mimeType:uploadReqeust.mimeType];
            }else{
                [formData appendPartWithFormData:uploadReqeust.file name:uploadReqeust.name];
            }
        } progress:nil success:success failure:failure];
    }
    else if ([request isKindOfClass:[LBUniversalRequest class]]){
        //JSON结构通用型数据
        LBUniversalRequest *universalRequest = (LBUniversalRequest*)request;
        [manamer GET:universalRequest.path parameters:universalRequest.params progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(task,responseObject);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(task,error);
        }];
    }
    else{
        //返回结构化JSON{code,message,data}
        //根据POST,GET动态调用manager下对应的方法
        NSString *method = [request.method uppercaseString];
        if ([method isEqualToString:@"POST"]) {
            [manamer POST:request.path parameters:request.params progress:nil success:success failure:failure];
        }else if([method isEqualToString:@"PUT"]){
            [manamer PUT:request.path parameters:request.params success:success failure:failure];
        }else if([method isEqualToString:@"DELETE"]){
            [manamer DELETE:request.path parameters:request.params success:success failure:failure];
        }else{
            [manamer GET:request.path parameters:request.params progress:nil success:success failure:failure];
        }

    }
}

///这个功能只提供给测试人员和开发人员使用
#if(defined RELEASE_TEST) || (defined DEBUG_TEST) || (defined DEBUG_DEV)
+ (void)untilTestByRequest:(LBRequest *)request
               URLResponse:(NSHTTPURLResponse *)taskResponse
              responseData:(id)responseObject
                 errorInfo:(NSError *)error;
    {
        [LBRequestSaveInfo requestSaveByRequest:request URLResponse:taskResponse responseData:responseObject errorInfo:error];
    }
#endif



+(void)request:(NSString *)path method:(NSString *)method params:(NSDictionary<NSString *,id> *)params completion:(void (^)(LBResponse *))completion{
    LBRequest *request = [[LBRequest alloc] init];
    request.path = path;
    request.method = method;
    request.encoding = LBRequestParameterEncodingJSON;
    request.params = params;
    request.completion = completion;
    [self request:request];
}
+(void)get:(NSString *)path params:(NSDictionary<NSString *,id> *)params completion:(void (^)(LBResponse *))completion{
    LBRequest *request = [[LBRequest alloc] init];
    request.path = path;
    request.method = @"GET";
    request.encoding = LBRequestParameterEncodingJSON;
    request.params = params;
    
    request.completion = completion;
    [self request:request];
}
+(void)post:(NSString *)path params:(NSDictionary<NSString *,id> *)params completion:(void (^)(LBResponse *))completion{
    LBRequest *request = [[LBRequest alloc] init];
    request.path = path;
    request.method = @"POST";
    request.encoding = LBRequestParameterEncodingJSON;
    request.params = params;
    request.completion = completion;
    [self request:request];
}
//返回一个通用的JSON,主要用来适配返回的json格式不按照LBResponse来的
+(void)get:(NSString *)path params:(NSDictionary<NSString *,id> *)params completion:(void (^)(id json))completion
 universal:(BOOL)universal{
    if (universal) {
        LBUniversalRequest *request = [[LBUniversalRequest alloc] init];
        request.path = path;
        request.method = @"GET";
        request.encoding = LBRequestParameterEncodingJSON;
        request.params = params;
        
        request.completion = completion;
        [self request:request];
    }
    else{
        [self get:path params:params completion:completion];
    }
    
}
+(void)post:(NSString *)path params:(NSDictionary<NSString *,id> *)params completion:(void (^)(id json))completion universal:(BOOL)universal{
    if (universal) {
        LBUniversalRequest *request = [[LBUniversalRequest alloc] init];
        request.path = path;
        request.method = @"POST";
        request.encoding = LBRequestParameterEncodingJSON;
        request.params = params;
        request.completion = completion;
        [self request:request];
    }
    else{
        [self post:path params:params completion:completion];
    }
    
}
/// 上传请求
+(void)upload:(NSString*)path file:(NSData*)file name:(NSString*)name fileName:(NSString*)fileName mimeType:(NSString*)mimeType params:(NSDictionary<NSString*,id>*)params completion:(void(^)(LBResponse* response))completion{
    LBUploadRequest *request = [[LBUploadRequest alloc] init];
    request.path = path;
    request.file = file;
    request.name = name;
    request.fileName = fileName;
    request.mimeType = mimeType;
    request.method = @"POST";
    request.encoding = LBRequestParameterEncodingJSON;
    request.params = params;
    request.completion = completion;
    [self request:request];
}
+(void)upload:(NSString *)path file:(NSData *)file name:(NSString *)name params:(NSDictionary<NSString *,id> *)params completion:(void (^)(LBResponse *))completion{
    LBUploadRequest *request = [[LBUploadRequest alloc] init];
    request.path = path;
    request.file = file;
    request.name = name;
    request.fileName = nil;
    request.mimeType = nil;
    request.method = @"POST";
    request.encoding = LBRequestParameterEncodingJSON;
    request.params = params;
    request.completion = completion;
    [self request:request];
}
+(void)downImage:(NSString*)path params:(NSDictionary<NSString*,id>*)params completion:(void(^)(id   responseObject))completion failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure{
   
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self setTokenAndHttps:manager];
    [manager GET:path parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //如果请求成功的话将responseObject保存在sucess Block中
        if (completion)
        {
            completion(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task,error);
        
    }];

}

//设置处理token等请求头,同时设置https证书问题
+ (void)setTokenAndHttps:(AFHTTPSessionManager *)manager{
    //HTTPS
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];
    NSData * certData =[NSData dataWithContentsOfFile:cerPath];
    NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //是否允许CA不信任的证书通过
    policy.allowInvalidCertificates = NO;
    //是否验证主机名
    policy.validatesDomainName = YES;
    // 设置证书
    [policy setPinnedCertificates:certSet];
    [manager setSecurityPolicy:policy];
    
    //设置登录用户token
    [manager.requestSerializer setValue:@"9363a0cbd49b03e9d8dd83d03dbbaab6" forHTTPHeaderField:@"x-token"];
    //设置当前客户端类型
//    [manager.requestSerializer setValue:[LBVersionCheck shared].client forHTTPHeaderField:@"x-client"];
//    //设置当前版本
//    [manager.requestSerializer setValue:[LBVersionCheck shared].currentVersion forHTTPHeaderField:@"x-version"];
//    //设置网络类型
//    [manager.requestSerializer setValue:[LBNetWork shared].netWorkType forHTTPHeaderField:@"x-nettype"];
//    //设置设备信息
//    [manager.requestSerializer setValue:[LBVersionCheck shared].idfa forHTTPHeaderField:@"x-device"];
    //设置广告id
    [manager.requestSerializer setValue:[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] forHTTPHeaderField:@"x-adv"];
//    //设置区域信息
//    [manager.requestSerializer setValue:[LBAreaManager sharedManager].currentArea.cityName forHTTPHeaderField:@"x-area"];
    //设置渠道
    [manager.requestSerializer setValue:
                     @"App Store" forHTTPHeaderField:@"x-channel"];
    NSLog(@"发送的header=%@",manager.requestSerializer.HTTPRequestHeaders);
}
@end


