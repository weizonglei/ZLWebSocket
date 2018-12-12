//
//  ZLWebSocketManager.m
//  Wei_ProtocolBuffer
//
//  Created by wzl on 2018/10/26.
//  Copyright © 2018 wzl. All rights reserved.
//

#import "ZLWebSocketManager.h"
#import "ImdataProto.pbobjc.h"
#import "ZLHttpRequestManager.h"
#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self

NSString * const kNeedPayOrderNote               = @"kNeedPayOrderNote";
NSString * const kWebSocketDidOpenNote           = @"kWebSocketDidOpenNote";
NSString * const kWebSocketDidCloseNote          = @"kWebSocketDidCloseNote";
NSString * const kWebSocketdidReceiveMessageNote = @"kWebSocketdidReceiveMessageNote";

NSInteger reConnectCount = 0;//用来记录重连次数的标记

@interface ZLWebSocketManager()<SRWebSocketDelegate>
{
    int _index;
    NSTimer * heartBeat;
}

@property (nonatomic,strong) SRWebSocket *socket;

@property (nonatomic,copy) NSString *urlString;

@property (nonatomic,strong) IMData *imData;//连接成功以后从后台拿到的初始化参数
    
    
@end

@implementation ZLWebSocketManager

+(ZLWebSocketManager *)instance{
    static ZLWebSocketManager *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[ZLWebSocketManager alloc] init];
    });
    return Instance;
}

#pragma mark ----------- public methods
-(void)SRWebSocketOpenWithURLString:(NSString *)urlString{
    //如果是同一个url  return
    if (self.socket) {
        return;
    }
    if (!urlString) {
        return;
    }
    self.urlString = urlString;
    self.socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    NSLog(@"请求的websocket地址：%@",self.socket.url.absoluteString);
    
    self.socket.delegate = self;   //SRWebSocketDelegate 协议
    
    [self.socket open];     //开始连接
}


-(void)SRWebSocketClose{
    if (self.socket){
        [self.socket close];
        self.socket = nil;
        //断开连接时销毁心跳
        [self destoryHeartBeat];
    }
}
-(void)sendMessageWithIMdata:(IMData *)imdata
                        data:(NSData *)data
                 contentType:(NSString *)contentType
                      height:(NSString *)height
                       width:(NSString *)width
                     success:(void(^)(NSDictionary *data))success{
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                
                [weakSelf messageTypeHandleWithIMData:imdata data:data contentType:contentType height:height width:width success:^(NSDictionary *data) {
                    success(data);
                }];
                
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                
                [self reConnect];
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                
                NSLog(@"重连");
                
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败");
            NSLog(@"其实最好是发送前判断一下网络状态比较好");
        }
    });

}

-(void)messageTypeHandleWithIMData:(IMData *)imdata
                              data:(NSData *)data
                       contentType:(NSString *)contentType
                            height:(NSString *)height
                             width:(NSString *)width
                           success:(void(^)(NSDictionary *data))success{
    WeakSelf(ws);
    /** 消息类型：text=文本 audio=音频 file=文件 position=定位 custom=自定义 system=系统消息 */
    if ([imdata.msgData.msgType isEqualToString:@"text"] ||
        [imdata.msgData.msgType isEqualToString:@"position"]) {
        [self.socket send:[imdata data]];
    }else if ([imdata.msgData.msgType isEqualToString:@"audio"] ||
              [imdata.msgData.msgType isEqualToString:@"file"]){
        //上传到OSS获取fileName
        [ZLHttpRequestManager zl_updateToOSSWithdata:data contentType:contentType success:^(NSString *fileName) {
            //通过fileName获取完整的URL字符串
            [ZLHttpRequestManager getObjectUrlWithFileType:@"-1" height:height key:fileName width:width success:^(NSDictionary *data) {
                success(data);
                imdata.msgData.msgBody = [NSString stringWithFormat:@"%@",data];
                [weakSelf sendData:[imdata data]];
            } fail:^(NSString *message) {
                NSLog(@"%@",message);
            }];
        } fail:^(NSString *message) {
            NSLog(@"%@",message);
        }];
    }else{
        [self.socket send:[imdata data]];
    }
}

- (void)sendData:(id)data {
    NSLog(@"socketSendData --------------- %@",data);
    
    WeakSelf(ws);
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
    
    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                [weakSelf.socket send:data];    // 发送数据
                
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
                NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                
                [self reConnect];
                
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
                
                NSLog(@"重连");
                
                [self reConnect];
            }
        } else {
            NSLog(@"没网络，发送失败");
            NSLog(@"其实最好是发送前判断一下网络状态比较好");
        }
    });
}

#pragma mark - **************** private mothodes
//重连机制
- (void)reConnect
{
    [self SRWebSocketClose];
    //前三次每隔30秒试⼀次是否能连上，若3次之后连不上，第四次隔5分钟重试，第五次隔10分钟重试，第六次隔15分钟重试，第七次隔30分钟重试，终⽌重连
    reConnectCount = reConnectCount + 1;
    if (reConnectCount > 0 && reConnectCount < 4) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.socket = nil;
            [self SRWebSocketOpenWithURLString:self.urlString];
            NSLog(@"重连");
        });
    }else if (reConnectCount >= 4 && reConnectCount < 7){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * (reConnectCount - 3 ) * 60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.socket = nil;
            [self SRWebSocketOpenWithURLString:self.urlString];
            NSLog(@"重连");
        });
    }else{
        return;
    }
    
}


//取消心跳
- (void)destoryHeartBeat
{
    dispatch_main_async_safe(^{
        if (heartBeat) {
            if ([heartBeat respondsToSelector:@selector(isValid)]){
                if ([heartBeat isValid]){
                    [heartBeat invalidate];
                    heartBeat = nil;
                }
            }
        }
    })
}

//初始化心跳
//在通讯过程中，可能会出现通道阻塞，连接中断，为了保证通道畅通，前端每15秒发起一次⼼跳，然后后端及时 响应，两边同时异步处理。如果前端30秒未收到响应，则关闭连接，重新连接。后端30秒钟未收到心跳，关闭通道回收资源
- (void)initHeartBeat
{
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        //前端发送心跳间隔时间由初始化时后台所给
        heartBeat = [NSTimer timerWithTimeInterval:self.imData.initData.heartbeatMs/1000 target:self selector:@selector(sentheart) userInfo:nil repeats:YES];
        //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
        [[NSRunLoop currentRunLoop] addTimer:heartBeat forMode:NSRunLoopCommonModes];
    })
}

-(void)sentheart{
    //发送心跳 和后台可以约定发送什么内容  一般可以调用ping  我这里根据后台的要求 发送了data给他
    IMData *imData = [IMData new];
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", time];

    imData.timestamp = [timeSp integerValue];
    imData.type = 4;
    
    NSData *data = [imData data];
    [self sendData:data];
}

//pingPong
- (void)ping{
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil];
    }
}

#pragma mark - socket delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {

    //发送心跳
    [self sentheart];

    if (webSocket == self.socket) {
        NSLog(@"************************** socket 连接成功************************** ");
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidOpenNote object:nil];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket 连接失败************************** ");
        _socket = nil;
        //连接失败就重连
        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket连接断开************************** ");
        NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
        [self SRWebSocketClose];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketDidCloseNote object:nil];
    }
}

/*该函数是接收服务器发送的pong消息，其中最后一个是接受pong消息的，
 在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，
 用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，
 我的理解就是建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
 */
-(void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload{
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"reply===%@",reply);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    if (webSocket == self.socket) {
        NSLog(@"************************** socket收到数据了************************** ");
        NSLog(@"message:%@",message);
        self.imData = [IMData parseFromData:message error:nil];
        
        //初始化时使用后台返回的参数来开启心跳
        if (self.imData.type == 1) {
            //开启心跳
            [self initHeartBeat];
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:kWebSocketdidReceiveMessageNote object:message];
    }
}

#pragma mark - **************** setter getter
- (SRReadyState)socketReadyState{
    return self.socket.readyState;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
