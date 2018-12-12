//
//  ZLWebSocketManager.h
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/10/26.
//  Copyright © 2018 wzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>
#import "ImdataProto.pbobjc.h"


extern NSString * const kNeedPayOrderNote;
extern NSString * const kWebSocketDidOpenNote;
extern NSString * const kWebSocketDidCloseNote;
extern NSString * const kWebSocketdidReceiveMessageNote;


@interface ZLWebSocketManager : NSObject


// 获取连接状态
@property (nonatomic,assign,readonly) SRReadyState socketReadyState;


+ (ZLWebSocketManager *)instance;

/**
 开启连接
 */
-(void)SRWebSocketOpenWithURLString:(NSString *)urlString;//

/**
 关闭连接
 */
-(void)SRWebSocketClose;

/**
 发送文字数据
 */
-(void)sendData:(id)data;//

/**
 发送文件消息

 @param imdata IMData模型 (必传)
 @param data 文件二进制 (非图片置nil)
 @param contentType 文件类型
 @param height 从OSS获取图片高（非图片置nil）
 @param width 从OSS获取图片宽（非图片置nil）
 @param success 返回的完整文件地址
 */
-(void)sendMessageWithIMdata:(IMData *)imdata
                        data:(NSData *)data
                 contentType:(NSString *)contentType
                      height:(NSString *)height
                       width:(NSString *)width
                     success:(void(^)(NSDictionary *data))success;


@end
