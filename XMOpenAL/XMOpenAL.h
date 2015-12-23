//
//  XMOpenAL.h
//  XMOpenAL
//
//  Created by mifit on 15/12/8.
//  Copyright © 2015年 mifit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMOpenAL : NSObject
- (BOOL)initOpenAl;
- (void)playSound;
- (void)stopSound;

/// 将收到的pcm数据放到缓存器中，再拿出来播放
- (void)openAudio:(unsigned char*)pBuffer length:(UInt32)pLength;

/// 清除已存在的buffer
- (void)clearOpenAL;
@end
